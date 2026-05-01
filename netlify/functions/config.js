exports.handler = async function () {
  const supabaseUrl = process.env.SUPABASE_URL || '';
  const supabaseAnonKey = process.env.SUPABASE_ANON_KEY || '';

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'no-store, no-cache, must-revalidate, proxy-revalidate',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify({
      ok: Boolean(supabaseUrl && supabaseAnonKey),
      supabaseUrl,
      supabaseAnonKey,
      message: supabaseUrl && supabaseAnonKey
        ? 'Supabase config loaded from Netlify Environment Variables.'
        : 'Missing SUPABASE_URL or SUPABASE_ANON_KEY in Netlify Environment Variables.'
    })
  };
};
