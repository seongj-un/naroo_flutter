const backendBaseUrl =
  process.env.NAROO_BACKEND_PROXY_URL ||
  "https://backend-production-688a6.up.railway.app";

const requestHopByHopHeaders = new Set([
  "connection",
  "content-length",
  "host",
  "transfer-encoding",
]);

const responseHopByHopHeaders = new Set([
  "connection",
  "content-length",
  "content-encoding",
  "transfer-encoding",
  "set-cookie",
]);

function buildTargetUrl(req) {
  const proxiedPath = req.query.path;
  const path = Array.isArray(proxiedPath)
    ? proxiedPath.join("/")
    : typeof proxiedPath === "string"
      ? proxiedPath
      : "";
  const search = new URL(req.url, "https://narooflutter.vercel.app").searchParams;
  search.delete("path");
  const query = search.toString();
  return `${backendBaseUrl}/api/${path}${query ? `?${query}` : ""}`;
}

function forwardableRequestHeaders(headers) {
  const forwarded = new Headers();
  for (const [name, value] of Object.entries(headers)) {
    if (value == null || requestHopByHopHeaders.has(name.toLowerCase())) {
      continue;
    }

    if (Array.isArray(value)) {
      forwarded.set(name, value.join(", "));
      continue;
    }

    forwarded.set(name, value);
  }
  return forwarded;
}

async function readRequestBody(req) {
  const chunks = [];
  for await (const chunk of req) {
    chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
  }
  if (chunks.length === 0) {
    return undefined;
  }
  return Buffer.concat(chunks);
}

module.exports = async function handler(req, res) {
  const method = req.method || "GET";
  const targetUrl = buildTargetUrl(req);
  const headers = forwardableRequestHeaders(req.headers);
  const body =
    method === "GET" || method === "HEAD" ? undefined : await readRequestBody(req);

  const backendResponse = await fetch(targetUrl, {
    method,
    headers,
    body,
    redirect: "manual",
  });

  res.statusCode = backendResponse.status;

  for (const [name, value] of backendResponse.headers) {
    if (responseHopByHopHeaders.has(name.toLowerCase())) {
      continue;
    }
    res.setHeader(name, value);
  }

  if (typeof backendResponse.headers.getSetCookie === "function") {
    const setCookies = backendResponse.headers.getSetCookie();
    if (setCookies.length > 0) {
      res.setHeader("set-cookie", setCookies);
    }
  } else {
    const setCookie = backendResponse.headers.get("set-cookie");
    if (setCookie) {
      res.setHeader("set-cookie", setCookie);
    }
  }

  const responseBuffer = Buffer.from(await backendResponse.arrayBuffer());
  res.end(responseBuffer);
};
