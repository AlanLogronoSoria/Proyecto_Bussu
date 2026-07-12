// =============================================================================
// Andes Mobility: Edge Function - Validate Device Binding (v2)
//
// C03 FIX: Agrega validación JWT del header Authorization.
// Solo el usuario autenticado puede vincular/validar su propio dispositivo.
// =============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
// Fix 5: usar anon key en lugar de service_role key
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

serve(async (req: Request) => {
  try {
    // C03 FIX: Validar JWT del header Authorization
    const authHeader = req.headers.get("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return new Response(
        JSON.stringify({ error: "No autorizado: token JWT requerido" }),
        { status: 401 },
      );
    }

    const jwt = authHeader.replace("Bearer ", "");

    // Fix 5: usar anon key para getUser (no requiere privilegios elevados)
    const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser(jwt);

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "No autorizado: token JWT inválido" }),
        { status: 401 },
      );
    }

    // Leer body
    const body = await req.json();
    const { user_id, device_id } = body;

    if (!user_id || !device_id) {
      return new Response(
        JSON.stringify({ error: "user_id y device_id son requeridos" }),
        { status: 400 },
      );
    }

    // C03 FIX: Verificar que el JWT pertenece al user_id del request
    if (user.id !== user_id) {
      return new Response(
        JSON.stringify({ error: "No autorizado: el token no coincide con el user_id" }),
        { status: 403 },
      );
    }

    const { data: profile, error } = await supabaseClient
      .from("profiles")
      .select("device_id")
      .eq("id", user_id)
      .single();

    if (error || !profile) {
      return new Response(
        JSON.stringify({ error: "Perfil no encontrado" }),
        { status: 404 },
      );
    }

    // Primer login: vincular dispositivo (requiere service_role para escribir)
    if (!profile.device_id) {
      const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
      await supabaseAdmin
        .from("profiles")
        .update({ device_id })
        .eq("id", user_id);

      return new Response(
        JSON.stringify({ bound: true, message: "Dispositivo vinculado exitosamente" }),
        { status: 200 },
      );
    }

    // Dispositivo ya vinculado: validar coincidencia
    if (profile.device_id !== device_id) {
      return new Response(
        JSON.stringify({
          bound: false,
          blocked: true,
          message: "Dispositivo no autorizado. La sesión ha sido bloqueada.",
        }),
        { status: 403 },
      );
    }

    return new Response(
      JSON.stringify({ bound: true, validated: true }),
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
