const app=document.getElementById('app');
app.innerHTML='<div class="card"><h1>Vision One Live</h1><p id="s">Loading...</p><pre id="out"></pre></div>';
function js(url){return new Promise((ok,fail)=>{const x=document.createElement('script');x.src=url;x.onload=ok;x.onerror=fail;document.head.appendChild(x);});}
async function main(){
 const r=await fetch('/api/config',{cache:'no-store'});
 const cfg=await r.json();
 if(!cfg.ok){s.textContent='Config missing';out.textContent=JSON.stringify(cfg,null,2);return;}
 await js('https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2');
 s.textContent='Client loaded';
 out.textContent='Ready';
}
main();