module.exports = function handler(req, res) {
  res.setHeader('Cache-Control', 'no-store, max-age=0');
  res.setHeader('Content-Type', 'application/json; charset=utf-8');

  const databaseUrl =
    process.env.VISION_ONE_DATABASE_URL ||
    process.env.NEXT_PUBLIC_SUPABASE_URL ||
    'https://jsyhlsxoaykksvoswktu.supabase.co';

  const browserToken =
    process.env.VISION_ONE_BROWSER_TOKEN ||
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ||
    'sb_publishable_9pqdtO9dZ9Iy1XjiWmZHAQ_DahGyW2q';

  if (!databaseUrl || !browserToken) {
    return res.status(500).json({
      ok: false,
      message: 'Missing Vision One public browser configuration in Vercel project settings.'
    });
  }

  return res.status(200).json({
    ok: true,
    supabaseUrl: databaseUrl,
    supabaseAnonKey: browserToken
  });
};
