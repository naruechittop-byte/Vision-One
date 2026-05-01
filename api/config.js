export default function handler(req, res) {
  const supabaseUrl = process.env.SUPABASE_URL || '';
  const supabaseAnonKey = process.env.SUPABASE_ANON_KEY || '';

  res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');
  res.setHeader('Content-Type', 'application/json; charset=utf-8');

  res.status(200).json({
    ok: Boolean(supabaseUrl && supabaseAnonKey),
    supabaseUrl,
    supabaseAnonKey,
    message: supabaseUrl && supabaseAnonKey
      ? 'Supabase config loaded from Vercel Environment Variables.'
      : 'Missing SUPABASE_URL or SUPABASE_ANON_KEY in Vercel Environment Variables.'
  });
}
