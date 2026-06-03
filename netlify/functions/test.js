exports.handler = async (event) => {
  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
    body: JSON.stringify({
      ok: true,
      tieneApiKey: !!process.env.ANTHROPIC_API_KEY,
      keyInicio: process.env.ANTHROPIC_API_KEY ? process.env.ANTHROPIC_API_KEY.slice(0, 15) + '...' : 'NO CONFIGURADA'
    })
  };
};
