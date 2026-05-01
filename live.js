const app=document.getElementById('app');
app.innerHTML='<div class="card"><h1>Vision One Live</h1><p id="s">Loading config...</p><pre id="out"></pre></div>';
async function main(){
 const r=await fetch('/api/config',{cache:'no-store'});
 const cfg=await r.json();
 document.getElementById('s').textContent=cfg.ok?'Config OK':'Config missing';
 document.getElementById('out').textContent=JSON.stringify({ok:cfg.ok,message:cfg.message},null,2);
}
main();