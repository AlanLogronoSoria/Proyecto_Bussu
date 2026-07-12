// =============================================================================
// BUSSU: Edge Function - Send Push Notification (v3)
//
// Features:
// 1. Webhook signature verification (x-supabase-signature)
// 2. Real RS256 JWT via WebCrypto for FCM OAuth2
// 3. Per-token error handling with parallel sends
// =============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { create, getNumericDate } from "https://deno.land/x/djwt@v3.0.2/mod.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const SUPABASE_WEBHOOK_SECRET = Deno.env.get("SUPABASE_WEBHOOK_SECRET") ?? "";

// Obtener access token de Google OAuth2 para FCM v1
async function getFcmAccessToken(): Promise<string> {
  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: await createFcmJwt(),
    }),
  });
  const data = await response.json();
  return data.access_token;
}

async function createFcmJwt(): Promise<string> {
  const clientEmail = Deno.env.get("FIREBASE_CLIENT_EMAIL");
  const privateKey = Deno.env.get("FIREBASE_PRIVATE_KEY");

  if (!clientEmail || !privateKey) {
    throw new Error(
      "FIREBASE_CLIENT_EMAIL y FIREBASE_PRIVATE_KEY deben configurarse "
      + "como secrets de la Edge Function en Supabase."
    );
  }

  const now = getNumericDate(0);
  const oneHour = getNumericDate(3600);
  const scope = "https://www.googleapis.com/auth/firebase.messaging";
  const audience = "https://oauth2.googleapis.com/token";

  const jwt = await create(
    { alg: "RS256", typ: "JWT" },
    {
      iss: clientEmail,
      scope: scope,
      aud: audience,
      exp: oneHour,
      iat: now,
    },
    privateKey,
  );

  return jwt;
}

interface WebhookPayload {
  type: "INSERT" | "UPDATE" | "DELETE";
  table: string;
  record: {
    id: string;
    bus_id: string;
    stop_id: string;
    trip_id: string;
    event_type: "arrival" | "departure";
    occurred_at: string;
  };
}

// C04 FIX: Verificar firma HMAC del webhook
// Si SUPABASE_WEBHOOK_SECRET no está configurado, se rechaza la petición.
// En desarrollo local puedes configurarlo como "dev-secret".
async function verifyWebhookSignature(req: Request, rawBody: string): Promise<boolean> {
  if (!SUPABASE_WEBHOOK_SECRET) {
    console.error("SUPABASE_WEBHOOK_SECRET no configurado — rechazando petición");
    return false;
  }

  const signature = req.headers.get("x-supabase-signature");
  if (!signature) return false;

  const keyBytes = new TextEncoder().encode(SUPABASE_WEBHOOK_SECRET);
  const dataBytes = new TextEncoder().encode(rawBody);
  const hmac = await crypto.subtle.importKey("raw", keyBytes, { name: "HMAC", hash: "SHA-256" }, false, ["sign"]);
  const computed = await crypto.subtle.sign("HMAC", hmac, dataBytes);
  const computedHex = Array.from(new Uint8Array(computed)).map((b) => b.toString(16).padStart(2, "0")).join("");

  return computedHex === signature;
}

serve(async (req: Request) => {
  try {
    if (req.method !== "POST") {
      return new Response(
        JSON.stringify({ error: "Method not allowed" }),
        { status: 405, headers: { "Allow": "POST" } },
      );
    }

    const rawBody = await req.text();

    // C04 FIX: Verificar firma del webhook
    const isValid = await verifyWebhookSignature(req, rawBody);
    if (!isValid) {
      return new Response(
        JSON.stringify({ error: "Firma de webhook inválida" }),
        { status: 401 },
      );
    }

    const payload: WebhookPayload = JSON.parse(rawBody);

    if (payload.record.event_type !== "arrival") {
      return new Response(
        JSON.stringify({ message: "Solo se notifican llegadas" }),
        { status: 200 },
      );
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // Obtener nombre de la parada
    const { data: stop } = await supabase
      .from("stops")
      .select("name")
      .eq("id", payload.record.stop_id)
      .single();

    const stopName = stop?.name ?? "tu parada";

    // Buscar usuarios con presencia reciente
    const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000).toISOString();
    const { data: presences } = await supabase
      .from("user_stop_presence")
      .select("user_id")
      .eq("stop_id", payload.record.stop_id)
      .gte("detected_at", fiveMinutesAgo);

    if (!presences || presences.length === 0) {
      return new Response(
        JSON.stringify({ message: "No hay usuarios para notificar" }),
        { status: 200 },
      );
    }

    const userIds = presences.map((p: { user_id: string }) => p.user_id);

    const { data: tokens } = await supabase
      .from("device_tokens")
      .select("token, platform")
      .in("user_id", userIds);

    if (!tokens || tokens.length === 0) {
      return new Response(
        JSON.stringify({ message: "No hay tokens registrados" }),
        { status: 200 },
      );
    }

    // C04 FIX: Usar OAuth2 token para FCM v1
    const fcmAccessToken = await getFcmAccessToken();
    const projectId = Deno.env.get("FCM_PROJECT_ID") ?? "bussu-app";

    // Enviar en paralelo a todos los tokens
    const sendResults = await Promise.allSettled(
      (tokens as Array<{ token: string; platform: string }>).map(async (t) => {
        const response = await fetch(
          `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${fcmAccessToken}`,
            },
            body: JSON.stringify({
              message: {
                token: t.token,
                notification: {
                  title: "¡Bus llegando!",
                  body: `El bus está llegando a ${stopName}`,
                },
                data: {
                  stop_id: payload.record.stop_id,
                  bus_id: payload.record.bus_id,
                  event_type: payload.record.event_type,
                },
              },
            }),
          },
        );

        if (response.ok) {
          return { status: "sent" as const, token: t };
        }
        if (response.status === 404) {
          await supabase.from("device_tokens").delete().eq("token", t.token);
          return { status: "invalid" as const, token: t };
        }
        return { status: "failed" as const, token: t };
      }),
    );

    let sentCount = 0;
    let failCount = 0;
    for (const r of sendResults) {
      if (r.status === "fulfilled") {
        if (r.value.status === "sent") sentCount++;
        else failCount++;
      } else {
        failCount++;
      }
    }

    return new Response(
      JSON.stringify({ success: true, sent: sentCount, failed: failCount }),
      { status: 200 },
    );
  } catch (error) {
    console.error("Error:", error);
    return new Response(
      JSON.stringify({ error: "Internal server error" }),
      { status: 500 },
    );
  }
});
