module.exports = function handler(req, res) {
  res.setHeader('Cache-Control', 'no-store, max-age=0');
  res.setHeader('Content-Type', 'application/json; charset=utf-8');

  const databaseUrl = process.env.VISION_ONE_DATABASE_URL;
  const browserToken = process.env.VISION_ONE_BROWSER_TOKEN;

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
