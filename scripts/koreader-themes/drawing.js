// Drawing code of Babel's Bookshelf themes, run in a browser canvas by build.mjs.
// Every piece is drawn procedurally (noise, wood grain, stone, glass and metal gradients).
let S=2; // device pixels per drawing unit, set per piece

function mulberry(a){return function(){a|=0;a=a+0x6D2B79F5|0;let t=Math.imul(a^a>>>15,1|a);t=t+Math.imul(t^t>>>7,61|t)^t;return((t^t>>>14)>>>0)/4294967296}}
function noise2(seed){
  const r=mulberry(seed),p=new Uint8Array(512),g=new Float32Array(256);
  for(let i=0;i<256;i++){p[i]=i;g[i]=r()*2-1}
  for(let i=255;i>0;i--){const j=Math.floor(r()*(i+1));[p[i],p[j]]=[p[j],p[i]]}
  for(let i=0;i<256;i++)p[i+256]=p[i];
  const fade=t=>t*t*(3-2*t);
  return (x,y)=>{const xi=Math.floor(x),yi=Math.floor(y),xf=x-xi,yf=y-yi,X=xi&255,Y=yi&255;
    const a=g[p[p[X]+Y]],b=g[p[p[X+1]+Y]],c=g[p[p[X]+Y+1]],d=g[p[p[X+1]+Y+1]],u=fade(xf),v=fade(yf);
    return a+(b-a)*u+(c-a)*v+(a-b-c+d)*u*v};
}
function fbm(n,x,y,o=4){let s=0,a=.5,f=1;for(let i=0;i<o;i++){s+=a*n(x*f,y*f);f*=2;a*=.5}return s}
function paint(ctx,x0,y0,w,h,fn){ // fn(x,y) in CSS px → [r,g,b,a?]
  const X=Math.round(x0*S),Y=Math.round(y0*S),Wd=Math.round(w*S),Hd=Math.round(h*S);
  const img=ctx.createImageData(Wd,Hd),d=img.data;
  for(let j=0;j<Hd;j++)for(let i=0;i<Wd;i++){const c=fn(x0+i/S,y0+j/S),k=(j*Wd+i)*4;d[k]=c[0];d[k+1]=c[1];d[k+2]=c[2];d[k+3]=c[3]===undefined?255:c[3]}
  const tmp=document.createElement('canvas');tmp.width=Wd;tmp.height=Hd;tmp.getContext('2d').putImageData(img,0,0);
  ctx.save();ctx.setTransform(1,0,0,1,0,0);ctx.drawImage(tmp,X,Y);ctx.restore();
}
const hex=h=>[parseInt(h.slice(1,3),16),parseInt(h.slice(3,5),16),parseInt(h.slice(5,7),16)];
const lerp=(a,b,t)=>a+(b-a)*t, clamp=(v,a=0,b=1)=>Math.max(a,Math.min(b,v));
const mixc=(a,b,t)=>[lerp(a[0],b[0],t),lerp(a[1],b[1],t),lerp(a[2],b[2],t)];
function ramp(stops,t){t=clamp(t);for(let i=1;i<stops.length;i++){if(t<=stops[i][0]){const[a,ca]=stops[i-1],[b,cb]=stops[i];return mixc(ca,cb,(t-a)/(b-a))}}return stops[stops.length-1][1]}
function wood(n,x,y,dark,light,scale=1){ // horizontal grain
  const warp=fbm(n,x*.004*scale,y*.02*scale,3)*6;
  const rings=.5+.5*Math.sin((y*.22*scale+warp*3+fbm(n,x*.01,y*.05,2)*4));
  const fib=fbm(n,x*.08,y*1.2,2);
  const t=clamp(Math.pow(rings,1.6)*.6+fib*.5+.3);
  return mixc(hex(dark),hex(light),t);
}
function shade(c,k){return [c[0]*k,c[1]*k,c[2]*k]}
function rr(ctx,x,y,w,h,r){ctx.beginPath();ctx.roundRect(x,y,w,h,r)}
function ambient(ctx,...a){if(!EXPORT.on)glow(ctx,...a)}
function glow(ctx,x,y,r,col,a){const g=ctx.createRadialGradient(x,y,0,x,y,r);g.addColorStop(0,`rgba(${col},${a})`);g.addColorStop(1,`rgba(${col},0)`);ctx.save();ctx.globalCompositeOperation='lighter';ctx.fillStyle=g;ctx.fillRect(x-r,y-r,2*r,2*r);ctx.restore()}
function cellular(seed,cw,ch){ // jittered-grid Worley: distance to nearest and second nearest point
  const r=mulberry(seed),pts=new Map();
  const pt=(i,j)=>{const k=i*7919+j;if(!pts.has(k))pts.set(k,[(i+.15+r()*.7)*cw,(j+.15+r()*.7)*ch]);return pts.get(k)};
  return (x,y)=>{const ci=Math.floor(x/cw),cj=Math.floor(y/ch);let d1=1e9,d2=1e9,id=0;
    for(let i=ci-1;i<=ci+1;i++)for(let j=cj-1;j<=cj+1;j++){const p=pt(i,j),d=Math.hypot(p[0]-x,(p[1]-y)*1.25);if(d<d1){d2=d1;d1=d;id=i*31+j*17}else if(d<d2)d2=d}
    return [d1,d2,id]};
}
function flame(ctx,fx,fy,s=1){
  glow(ctx,fx,fy-6*s,26*s,'255,160,70',.55);
  const fg=ctx.createRadialGradient(fx,fy-4*s,0,fx,fy-6*s,9*s);fg.addColorStop(0,'#fffbe8');fg.addColorStop(.45,'#ffc768');fg.addColorStop(1,'rgba(255,100,30,0)');
  ctx.fillStyle=fg;ctx.beginPath();ctx.moveTo(fx,fy-17*s);ctx.bezierCurveTo(fx+5*s,fy-8*s,fx+4*s,fy,fx,fy);ctx.bezierCurveTo(fx-4*s,fy,fx-5*s,fy-8*s,fx,fy-17*s);ctx.fill();
  ctx.fillStyle='rgba(60,90,200,.55)';ctx.beginPath();ctx.ellipse(fx,fy-1.5*s,1.6*s,2.4*s,0,0,7);ctx.fill();
}
function candle(ctx,x,top,bottom,w,seed){
  const g=ctx.createLinearGradient(x,0,x+w,0);g.addColorStop(0,'#a8987e');g.addColorStop(.35,'#f4ecd8');g.addColorStop(1,'#8e816a');
  ctx.fillStyle=g;ctx.fillRect(x,top,w,bottom-top);
  const r=mulberry(seed);ctx.fillStyle='#f2e9d4';
  for(let k=0;k<3;k++){const dx=x+r()*(w-3),len=6+r()*18;ctx.beginPath();ctx.roundRect(dx,top,2.4+r()*1.2,len,1.4);ctx.fill();ctx.beginPath();ctx.arc(dx+1.5,top+len,1.8,0,7);ctx.fill()}
  ctx.fillStyle='#e6dcc4';ctx.beginPath();ctx.ellipse(x+w/2,top,w/2,2,0,0,7);ctx.fill();
  ctx.strokeStyle='#1a1410';ctx.lineWidth=1;ctx.beginPath();ctx.moveTo(x+w/2,top);ctx.lineTo(x+w/2+.6,top-4);ctx.stroke();
  flame(ctx,x+w/2+.6,top-3);
}
function bankersLamp(ctx,x,b){
  // base
  let g=ctx.createLinearGradient(x,0,x+70,0);g.addColorStop(0,'#6e5124');g.addColorStop(.4,'#f0d38a');g.addColorStop(1,'#6e5124');
  ctx.save();ctx.shadowColor='rgba(0,0,0,.6)';ctx.shadowBlur=8;ctx.fillStyle=g;ctx.beginPath();ctx.ellipse(x+35,b-4,34,6,0,0,Math.PI*2);ctx.fill();ctx.restore();
  ctx.fillStyle=g;ctx.fillRect(x+31,b-60,8,56);ctx.fillRect(x+12,b-62,46,4);
  // green glass shade: a half-cylinder, darker at the edges, lit from inside
  g=ctx.createLinearGradient(x-6,0,x+76,0);g.addColorStop(0,'#0f3a24');g.addColorStop(.35,'#3f9a62');g.addColorStop(.5,'#5fbb80');g.addColorStop(1,'#0c2c1c');
  ctx.save();ctx.shadowColor='rgba(0,0,0,.5)';ctx.shadowBlur=6;ctx.beginPath();ctx.moveTo(x-6,b-64);ctx.quadraticCurveTo(x+35,b-102,x+76,b-64);ctx.closePath();ctx.fillStyle=g;ctx.fill();ctx.restore();
  ctx.strokeStyle='#d8b878';ctx.lineWidth=1.5;ctx.beginPath();ctx.moveTo(x-6,b-64);ctx.lineTo(x+76,b-64);ctx.stroke();
  ctx.fillStyle='rgba(255,235,180,.9)';ctx.fillRect(x+4,b-63,62,2);
  glow(ctx,x+35,b-58,40,'255,210,130',.5);
  ctx.fillStyle='rgba(255,255,255,.22)';ctx.beginPath();ctx.ellipse(x+22,b-78,14,4,-.35,0,Math.PI*2);ctx.fill();
  // pull chain
  ctx.strokeStyle='#d8b878';ctx.lineWidth=.8;ctx.beginPath();ctx.moveTo(x+58,b-62);ctx.lineTo(x+60,b-40);ctx.stroke();ctx.fillStyle='#d8b878';ctx.beginPath();ctx.arc(x+60,b-39,1.8,0,7);ctx.fill();
}
function bookStack(ctx,x,b){
  const books=[[0,96,16,'#5b2a1c'],[6,84,13,'#26392d'],[2,90,14,'#3e2a1c'],[10,74,11,'#6b4a2a']];let y=b;
  books.forEach(([dx,w,h,c])=>{y-=h;const g=ctx.createLinearGradient(0,y,0,y+h);const cc=hex(c);g.addColorStop(0,`rgb(${shade(cc,1.2)})`);g.addColorStop(1,`rgb(${shade(cc,.6)})`);
    ctx.save();ctx.shadowColor='rgba(0,0,0,.5)';ctx.shadowBlur=5;ctx.shadowOffsetY=1;ctx.fillStyle=g;rr(ctx,x+dx,y,w,h,2);ctx.fill();ctx.restore();
    ctx.fillStyle='#e9dcc0';ctx.fillRect(x+dx+w-6,y+2,4,h-4);ctx.fillStyle='rgba(0,0,0,.15)';for(let k=0;k<h-4;k+=1.5)ctx.fillRect(x+dx+w-6,y+2+k,4,.4);
    ctx.fillStyle='#c9a865';ctx.fillRect(x+dx+8,y+h/2-.5,w-22,1)});
  // a pocket watch on top
  const cx=x+46,cy=y-8;ctx.save();ctx.shadowColor='rgba(0,0,0,.5)';ctx.shadowBlur=4;ctx.fillStyle='#b8924f';ctx.beginPath();ctx.ellipse(cx,cy+4,16,5,0,0,7);ctx.fill();ctx.restore();
  ctx.fillStyle='#efe4c8';ctx.beginPath();ctx.ellipse(cx,cy+3,12,3.6,0,0,7);ctx.fill();
}
function crystals(ctx,x,b){
  ambient(ctx,x+36,b-40,70,'150,120,255',.35);
  const facet=(pts,c1,c2)=>{const g=ctx.createLinearGradient(pts[0][0],pts[0][1],pts[2][0],pts[2][1]);g.addColorStop(0,c1);g.addColorStop(1,c2);ctx.beginPath();pts.forEach((p,i)=>i?ctx.lineTo(p[0],p[1]):ctx.moveTo(p[0],p[1]));ctx.closePath();ctx.fillStyle=g;ctx.fill()};
  const shard=(cx,w,h,lean)=>{const t=[cx+lean,b-h],l=[cx-w/2,b-h*.78],r=[cx+w/2,b-h*.8],bl=[cx-w/2,b],br=[cx+w/2,b];
    facet([t,l,bl,[cx,b]],'#e9e2ff','#6a4fd0');facet([t,[cx,b],br,r],'#b9a6ff','#3a2a8a');
    ctx.strokeStyle='rgba(255,255,255,.55)';ctx.lineWidth=.8;ctx.beginPath();ctx.moveTo(t[0],t[1]);ctx.lineTo(cx,b);ctx.stroke()};
  ctx.save();ctx.shadowColor='rgba(140,110,255,.8)';ctx.shadowBlur=14;
  shard(x+14,16,44,-4);shard(x+58,14,38,5);shard(x+34,22,78,2);shard(x+46,12,30,3);ctx.restore();
  ctx.fillStyle='#2a2448';ctx.beginPath();ctx.ellipse(x+36,b,40,4,0,0,7);ctx.fill();
}
function potion(ctx,x,b){
  ambient(ctx,x+30,b-34,60,'90,255,200',.35);
  ctx.save();ctx.beginPath();ctx.moveTo(x+24,b-70);ctx.lineTo(x+24,b-56);ctx.bezierCurveTo(x,b-48,x,b,x+30,b);ctx.bezierCurveTo(x+60,b,x+60,b-48,x+36,b-56);ctx.lineTo(x+36,b-70);ctx.closePath();
  ctx.fillStyle='rgba(200,240,255,.14)';ctx.fill();ctx.clip();
  const g=ctx.createLinearGradient(0,b-40,0,b);g.addColorStop(0,'#7dffd4');g.addColorStop(1,'#138a7a');ctx.fillStyle=g;ctx.fillRect(x,b-38,60,40);
  ctx.fillStyle='rgba(255,255,255,.75)';for(const[a,c,r]of[[22,-18,2],[34,-26,1.4],[28,-10,1.6]]){ctx.beginPath();ctx.arc(x+a,b+c,r,0,7);ctx.fill()}
  ctx.restore();
  ctx.strokeStyle='rgba(220,245,255,.7)';ctx.lineWidth=1;ctx.stroke();
  ctx.fillStyle='rgba(255,255,255,.4)';ctx.beginPath();ctx.ellipse(x+14,b-28,3,10,.3,0,7);ctx.fill();
  ctx.fillStyle='#7a5434';rr(ctx,x+22,b-80,16,11,2);ctx.fill();
  ctx.strokeStyle='#d9b46a';ctx.lineWidth=1;ctx.beginPath();ctx.moveTo(x+36,b-62);ctx.quadraticCurveTo(x+50,b-60,x+46,b-46);ctx.stroke();
  ctx.fillStyle='#e8dcc0';ctx.save();ctx.translate(x+46,b-44);ctx.rotate(.2);ctx.fillRect(-6,0,12,9);ctx.restore();
}
function candelabrum(ctx,x,b){
  ambient(ctx,x+42,b-110,170,'255,140,60',.25);
  const iron=(x0,x1)=>{const g=ctx.createLinearGradient(x0,0,x1,0);g.addColorStop(0,'#141214');g.addColorStop(.4,'#5c565a');g.addColorStop(1,'#141214');return g};
  ctx.save();ctx.shadowColor='rgba(0,0,0,.6)';ctx.shadowBlur=6;
  ctx.fillStyle=iron(x+18,x+66);ctx.beginPath();ctx.moveTo(x+18,b);ctx.lineTo(x+66,b);ctx.lineTo(x+52,b-8);ctx.lineTo(x+32,b-8);ctx.closePath();ctx.fill();
  ctx.fillStyle=iron(x+38,x+46);ctx.fillRect(x+39,b-62,6,54);
  ctx.beginPath();ctx.ellipse(x+42,b-30,6,4,0,0,7);ctx.fill();
  ctx.strokeStyle=iron(x,x+84);ctx.lineWidth=4;ctx.lineCap='round';
  ctx.beginPath();ctx.moveTo(x+42,b-58);ctx.bezierCurveTo(x+26,b-56,x+10,b-62,x+10,b-74);ctx.moveTo(x+42,b-58);ctx.bezierCurveTo(x+58,b-56,x+74,b-62,x+74,b-74);ctx.stroke();
  for(const cx of [10,42,74]){ctx.fillStyle=iron(x+cx-9,x+cx+9);ctx.beginPath();ctx.moveTo(x+cx-9,b-(cx===42?66:76));ctx.lineTo(x+cx+9,b-(cx===42?66:76));ctx.lineTo(x+cx+5,b-(cx===42?60:70));ctx.lineTo(x+cx-5,b-(cx===42?60:70));ctx.closePath();ctx.fill()}
  ctx.restore();
  candle(ctx,x+4,b-108,b-77,12,3);candle(ctx,x+35,b-128,b-67,14,4);candle(ctx,x+68,b-100,b-77,12,5);
  // wax pooled and dripped down the arms
  ctx.fillStyle='#e9dfc8';for(const[dx,dy,h]of[[6,-76,10],[78,-76,7],[40,-66,14]]){ctx.beginPath();ctx.roundRect(x+dx,b+dy,2.2,h,1.1);ctx.fill()}
}
function grimoire(ctx,x,b){
  // a thick leather book lying flat, metal corners, a clasp, a ribbon; a stub of candle on it
  const w=96,h=32,t=9;
  ctx.save();ctx.shadowColor='rgba(0,0,0,.65)';ctx.shadowBlur=8;ctx.shadowOffsetY=2;
  ctx.fillStyle='#e6dbc2';ctx.fillRect(x+6,b-h+3,w-10,h-6);
  ctx.restore();
  ctx.fillStyle='rgba(120,100,70,.35)';for(let k=0;k<h-8;k+=1.6)ctx.fillRect(x+8,b-h+4+k,w-14,.5);
  const lg=ctx.createLinearGradient(0,b-h,0,b);lg.addColorStop(0,'#5a1c22');lg.addColorStop(1,'#2a0c10');
  ctx.fillStyle=lg;ctx.beginPath();ctx.roundRect(x,b-h-t+6,w+4,t,2);ctx.fill();ctx.beginPath();ctx.roundRect(x,b-6,w+4,6,2);ctx.fill();
  ctx.beginPath();ctx.roundRect(x-4,b-h-2,14,h+2,[6,0,0,6]);ctx.fill();
  ctx.fillStyle='rgba(255,220,200,.12)';ctx.fillRect(x+2,b-h-t+7,w,1.2);
  for(const yy of [b-h+4,b-h+12,b-8]){ctx.fillStyle='#3a1014';ctx.fillRect(x-4,yy,14,3)}
  const metal=ctx.createLinearGradient(0,b-h-8,0,b);metal.addColorStop(0,'#d8c48a');metal.addColorStop(1,'#6e5a2a');ctx.fillStyle=metal;
  for(const[cx,cy]of[[x+w-8,b-h-2],[x+w-8,b-6]]){ctx.beginPath();ctx.moveTo(cx,cy);ctx.lineTo(cx+12,cy);ctx.lineTo(cx+12,cy+6);ctx.closePath();ctx.fill()}
  ctx.fillRect(x+w-2,b-h+2,8,h-8);ctx.fillStyle='#2a2010';ctx.beginPath();ctx.arc(x+w+2,b-h/2-1,1.6,0,7);ctx.fill();
  ctx.fillStyle='#8e1c26';ctx.beginPath();ctx.moveTo(x+60,b-6);ctx.lineTo(x+66,b-6);ctx.lineTo(x+66,b-1);ctx.lineTo(x+63,b-4);ctx.lineTo(x+60,b-1);ctx.closePath();ctx.fill();
  // the candle stub
  ctx.fillStyle='#d8cdb4';ctx.beginPath();ctx.ellipse(x+38,b-h-t+6,13,3,0,0,7);ctx.fill();
  candle(ctx,x+31,b-h-t-20,b-h-t+6,14,9);
  ctx.fillStyle='#efe6d2';ctx.beginPath();ctx.ellipse(x+38,b-h-t+5,10,2.4,0,0,7);ctx.fill();
}
function nouveauTile(){ // a tone-on-tone repeat: mirrored whiplash stems, poppies, seed heads
  const T=document.createElement('canvas'),w=180,h=240;T.width=w*S;T.height=h*S;const c=T.getContext('2d');c.scale(S,S);
  c.strokeStyle='rgba(214,186,120,.26)';c.fillStyle='rgba(214,186,120,.16)';c.lineWidth=1.3;c.lineCap='round';
  const half=s=>{c.save();if(s<0){c.translate(w,0);c.scale(-1,1)}
    c.beginPath();c.moveTo(90,240);c.bezierCurveTo(70,200,20,190,30,140);c.bezierCurveTo(38,100,80,110,70,80);c.bezierCurveTo(62,56,30,60,36,40);c.stroke();
    c.beginPath();c.moveTo(30,140);c.bezierCurveTo(10,130,4,110,14,98);c.stroke();
    c.beginPath();c.moveTo(70,80);c.bezierCurveTo(84,70,88,52,80,40);c.stroke();
    // leaves
    for(const[lx,ly,a]of[[44,172,-.9],[24,118,.6],[60,96,-.4]]){c.save();c.translate(lx,ly);c.rotate(a);c.beginPath();c.moveTo(0,0);c.bezierCurveTo(8,-6,22,-6,30,0);c.bezierCurveTo(22,6,8,6,0,0);c.fill();c.restore()}
    // a seed head
    c.beginPath();c.arc(14,96,4,0,7);c.fill();c.beginPath();c.arc(80,38,3,0,7);c.fill();
    c.restore()};
  half(1);half(-1);
  // the poppy at the crown, in the middle
  c.save();c.translate(90,34);for(let i=0;i<5;i++){c.rotate(Math.PI*2/5);c.beginPath();c.ellipse(0,-9,7,10,0,0,7);c.fill()}c.restore();
  c.beginPath();c.arc(90,34,4,0,7);c.strokeStyle='rgba(214,186,120,.35)';c.stroke();
  c.beginPath();c.moveTo(90,44);c.bezierCurveTo(96,90,84,140,90,240);c.strokeStyle='rgba(214,186,120,.2)';c.stroke();
  // little whiplash curls between repeats
  c.beginPath();c.moveTo(0,200);c.bezierCurveTo(14,192,16,178,6,174);c.bezierCurveTo(0,172,-2,180,4,182);c.stroke();
  return T;
}
function galleVase(ctx,x,b){
  // cameo glass: amber fading to plum, leaves cut in relief, a slender neck
  const body=()=>{ctx.beginPath();ctx.moveTo(x+14,b);ctx.bezierCurveTo(x-6,b-6,x-8,b-50,x+12,b-76);ctx.bezierCurveTo(x+18,b-86,x+16,b-110,x+18,b-122);ctx.lineTo(x+28,b-122);ctx.bezierCurveTo(x+30,b-110,x+28,b-86,x+34,b-76);ctx.bezierCurveTo(x+54,b-50,x+52,b-6,x+32,b);ctx.closePath()};
  ctx.save();body();ctx.shadowColor='rgba(0,0,0,.5)';ctx.shadowBlur=8;const g=ctx.createLinearGradient(0,b-122,0,b);g.addColorStop(0,'#5a2a4a');g.addColorStop(.5,'#c07a3a');g.addColorStop(1,'#f0c070');ctx.fillStyle=g;ctx.fill();ctx.restore();
  ctx.save();body();ctx.clip();
  ctx.fillStyle='rgba(60,30,40,.7)';
  for(const[lx,ly,a,s]of[[10,-30,-.6,1],[30,-46,.5,1.1],[16,-62,-.3,.8],[36,-20,.8,.9],[24,-90,.2,.6]]){ctx.save();ctx.translate(x+lx,b+ly);ctx.rotate(a);ctx.scale(s,s);ctx.beginPath();ctx.moveTo(0,0);ctx.bezierCurveTo(6,-8,18,-8,24,0);ctx.bezierCurveTo(18,8,6,8,0,0);ctx.fill();ctx.restore()}
  ctx.strokeStyle='rgba(60,30,40,.7)';ctx.lineWidth=1.4;ctx.beginPath();ctx.moveTo(x+8,b);ctx.bezierCurveTo(x+16,b-30,x+20,b-60,x+24,b-100);ctx.stroke();
  const hl=ctx.createLinearGradient(x,0,x+46,0);hl.addColorStop(0,'rgba(0,0,0,.35)');hl.addColorStop(.3,'rgba(255,240,210,.25)');hl.addColorStop(.45,'rgba(255,255,255,0)');hl.addColorStop(1,'rgba(0,0,0,.45)');ctx.fillStyle=hl;ctx.fillRect(x-10,b-124,70,126);
  ctx.restore();
  ctx.fillStyle='#4a2240';ctx.beginPath();ctx.ellipse(x+23,b-122,5.5,1.8,0,0,7);ctx.fill();
}
function tiffany2(ctx,x,b){
  ambient(ctx,x+40,b-70,110,'255,190,90',.28);
  const bronze=ctx.createLinearGradient(x,0,x+80,0);bronze.addColorStop(0,'#2a1e0e');bronze.addColorStop(.42,'#b8955a');bronze.addColorStop(1,'#22180a');
  ctx.save();ctx.shadowColor='rgba(0,0,0,.6)';ctx.shadowBlur=6;ctx.fillStyle=bronze;
  ctx.beginPath();ctx.moveTo(x+18,b);ctx.bezierCurveTo(x+24,b-12,x+30,b-10,x+34,b-18);ctx.lineTo(x+46,b-18);ctx.bezierCurveTo(x+50,b-10,x+56,b-12,x+62,b);ctx.closePath();ctx.fill();
  ctx.beginPath();ctx.moveTo(x+36,b-18);ctx.bezierCurveTo(x+30,b-40,x+46,b-52,x+38,b-70);ctx.lineTo(x+43,b-70);ctx.bezierCurveTo(x+52,b-50,x+36,b-40,x+44,b-18);ctx.closePath();ctx.fill();ctx.restore();
  // the shade: irregular leaded glass, darker at the rim, glowing from within
  const shade_=()=>{ctx.beginPath();ctx.moveTo(x-6,b-66);ctx.bezierCurveTo(x-2,b-92,x+18,b-116,x+40,b-118);ctx.bezierCurveTo(x+62,b-116,x+82,b-92,x+86,b-66);ctx.bezierCurveTo(x+70,b-62,x+10,b-62,x-6,b-66);ctx.closePath()};
  ctx.save();shade_();ctx.clip();
  const cellF=cellular(17,11,9),r=mulberry(8),cols=['#e8a63a','#f2c35a','#d9832e','#6f8f4e','#4f7a5a','#c9a14a','#e7b24a','#8aa35a'];
  const cache={};
  paint(ctx,x-6,b-118,92,56,(px,py)=>{const[d1,d2,id]=cellF(px*1.4,py*1.6);const col=cache[id]||(cache[id]=hex(cols[Math.abs(id)%cols.length]));
    const lift=Math.exp(-(((px-x-40)/38)**2+((py-b+64)/26)**2));let c=shade(col,.55+.75*lift);if(d2-d1<1.3)c=[40,28,14];return c.map(v=>Math.min(255,v))});
  // two dragonflies in the glass
  ctx.fillStyle='rgba(40,60,70,.8)';for(const[dx,dy]of[[22,-96],[60,-90]]){ctx.save();ctx.translate(x+dx,b+dy);ctx.fillRect(-.8,-2,1.6,14);for(const s of[-1,1]){ctx.beginPath();ctx.ellipse(s*7,1,7,2.2,s*.25,0,7);ctx.fill();ctx.beginPath();ctx.ellipse(s*6,5,6,2,s*-.2,0,7);ctx.fill()}ctx.restore()}
  ctx.restore();
  ctx.strokeStyle='#3a2a12';ctx.lineWidth=2;shade_();ctx.stroke();
  ctx.fillStyle=bronze;ctx.beginPath();ctx.arc(x+40,b-118,3.5,0,7);ctx.fill();
}
function decoTile(){ // fan scales: arcs with rays, offset every other row
  const T=document.createElement('canvas'),w=48,h=28;T.width=w*S;T.height=h*S;const c=T.getContext('2d');c.scale(S,S);
  const fan=(cx,cy)=>{c.strokeStyle='rgba(212,175,100,.34)';c.lineWidth=.8;for(const r of[24,18,12]){c.beginPath();c.arc(cx,cy,r,Math.PI,0);c.stroke()}
    c.strokeStyle='rgba(212,175,100,.2)';for(let i=1;i<8;i++){const a=Math.PI+Math.PI*i/8;c.beginPath();c.moveTo(cx+6*Math.cos(a),cy+6*Math.sin(a));c.lineTo(cx+24*Math.cos(a),cy+24*Math.sin(a));c.stroke()}
    c.fillStyle='rgba(212,175,100,.35)';c.beginPath();c.arc(cx,cy,2,Math.PI,0);c.fill()};
  fan(24,28);fan(0,14);fan(48,14);fan(24,0+28*0);
  return T;
}
function fanLamp(ctx,x,b){
  ambient(ctx,x+38,b-44,100,'255,215,140',.32);
  const g=ctx.createLinearGradient(x,0,x+76,0);g.addColorStop(0,'#8a6a2a');g.addColorStop(.5,'#f6dc9a');g.addColorStop(1,'#8a6a2a');
  ctx.fillStyle='#0a0a0a';ctx.fillRect(x+8,b-8,60,8);ctx.fillRect(x+16,b-14,44,6);ctx.fillStyle=g;ctx.fillRect(x+8,b-8,60,1.2);ctx.fillRect(x+16,b-14,44,1.2);
  ctx.fillStyle='#0a0a0a';ctx.fillRect(x+34,b-40,8,26);ctx.fillStyle=g;ctx.fillRect(x+37,b-40,2,26);
  const lg=ctx.createRadialGradient(x+38,b-40,2,x+38,b-40,40);lg.addColorStop(0,'#fff8e0');lg.addColorStop(.7,'#f2cf80');lg.addColorStop(1,'#c99a4a');
  ctx.save();ctx.shadowColor='rgba(255,210,130,.85)';ctx.shadowBlur=18;ctx.fillStyle=lg;ctx.beginPath();ctx.moveTo(x,b-40);ctx.arc(x+38,b-40,38,Math.PI,0);ctx.closePath();ctx.fill();ctx.restore();
  ctx.strokeStyle='#8a6a2a';ctx.lineWidth=1.1;for(let i=1;i<10;i++){const a=Math.PI+Math.PI*i/10;ctx.beginPath();ctx.moveTo(x+38,b-40);ctx.lineTo(x+38+38*Math.cos(a),b-40+38*Math.sin(a));ctx.stroke()}
  for(const r of[14,26]){ctx.beginPath();ctx.arc(x+38,b-40,r,Math.PI,0);ctx.stroke()}
  ctx.strokeStyle=g;ctx.lineWidth=2.4;ctx.beginPath();ctx.arc(x+38,b-40,38,Math.PI,0);ctx.stroke();ctx.beginPath();ctx.moveTo(x,b-40);ctx.lineTo(x+76,b-40);ctx.stroke();
}
function coupes(ctx,x,b){
  // a pair of champagne coupes and a chrome shaker
  ambient(ctx,x+40,b-40,70,'255,220,150',.18);
  const coupe=(cx,tilt)=>{ctx.save();ctx.translate(cx,b);ctx.rotate(tilt);
    ctx.fillStyle='rgba(230,235,240,.35)';ctx.beginPath();ctx.ellipse(0,-1.5,11,2.6,0,0,7);ctx.fill();
    ctx.strokeStyle='rgba(235,240,245,.85)';ctx.lineWidth=1.2;ctx.beginPath();ctx.moveTo(0,-2);ctx.lineTo(0,-34);ctx.stroke();
    const lq=ctx.createLinearGradient(0,-48,0,-34);lq.addColorStop(0,'#f6dc8a');lq.addColorStop(1,'#c9963a');
    ctx.fillStyle=lq;ctx.beginPath();ctx.moveTo(-19,-46);ctx.quadraticCurveTo(0,-26,19,-46);ctx.closePath();ctx.fill();
    ctx.fillStyle='rgba(255,250,230,.8)';ctx.beginPath();ctx.ellipse(0,-46,19,3,0,0,7);ctx.fill();
    ctx.strokeStyle='rgba(240,245,250,.9)';ctx.lineWidth=1;ctx.beginPath();ctx.ellipse(0,-48,21,3.6,0,0,7);ctx.stroke();ctx.beginPath();ctx.moveTo(-21,-48);ctx.quadraticCurveTo(0,-24,21,-48);ctx.stroke();
    ctx.fillStyle='rgba(255,255,255,.8)';for(const[a,c]of[[-4,-40],[3,-42],[0,-37]]){ctx.beginPath();ctx.arc(a,c,.8,0,7);ctx.fill()}
    ctx.restore()};
  // shaker
  const ch=ctx.createLinearGradient(x+46,0,x+76,0);ch.addColorStop(0,'#3a3a3e');ch.addColorStop(.3,'#f2f2f4');ch.addColorStop(.55,'#8a8a90');ch.addColorStop(1,'#2a2a2e');
  ctx.save();ctx.shadowColor='rgba(0,0,0,.6)';ctx.shadowBlur=6;ctx.fillStyle=ch;ctx.beginPath();ctx.moveTo(x+48,b);ctx.lineTo(x+74,b);ctx.lineTo(x+71,b-52);ctx.lineTo(x+51,b-52);ctx.closePath();ctx.fill();
  ctx.beginPath();ctx.moveTo(x+52,b-52);ctx.lineTo(x+70,b-52);ctx.lineTo(x+66,b-66);ctx.lineTo(x+56,b-66);ctx.closePath();ctx.fill();ctx.fillRect(x+58,b-74,6,8);ctx.restore();
  const gold=ctx.createLinearGradient(x+46,0,x+76,0);gold.addColorStop(0,'#8a6a2a');gold.addColorStop(.4,'#f6dc9a');gold.addColorStop(1,'#8a6a2a');ctx.fillStyle=gold;ctx.fillRect(x+49,b-30,24,2);ctx.fillRect(x+50,b-36,22,1);ctx.fillRect(x+51,b-53,20,2);
  coupe(x+20,0);coupe(x+100,0);
}

function wall_academia(ctx){
  const n=noise2(11),n2=noise2(12);
  // Walnut boards, a lamp's warm light from the left.
  paint(ctx,0,0,600,800,(x,y)=>{
    const board=Math.floor(x/100),bx=x-board*100;
    let c=wood(n,y*1.3+board*300,x*1.6+board*40,'#1d120b','#4a2f1d',.9); // vertical grain
    if(bx<1.5||bx>98.5)c=shade(c,.35);else if(bx<4)c=shade(c,1.12);
    const l=Math.exp(-(((x-90)/360)**2+((y-560)/420)**2));
    c=mixc(shade(c,.55),shade(c,1.25),l);
    return c.map(v=>Math.min(255,v));
  });
  // Raised panel moldings on each board pair.
  for(let i=0;i<3;i++){const x=20+i*200;ctx.strokeStyle='rgba(0,0,0,.45)';ctx.lineWidth=2;ctx.strokeRect(x+1,301,158,400);ctx.strokeStyle='rgba(255,210,150,.08)';ctx.strokeRect(x,300,158,400)}
  const vg=ctx.createRadialGradient(300,420,200,300,420,620);vg.addColorStop(0,'rgba(0,0,0,0)');vg.addColorStop(1,'rgba(0,0,0,.6)');ctx.fillStyle=vg;ctx.fillRect(0,0,600,800);
}

function wall_fantasy(ctx){
  const n=noise2(21),n2=noise2(22);
  paint(ctx,0,0,600,800,(x,y)=>{
    const v=y/800,base=ramp([[0,hex('#070a1e')],[.5,hex('#131a3d')],[1,hex('#0c2433')]],v);
    const cl=clamp(fbm(n,x*.006,y*.006,5)*1.4+.35),cl2=clamp(fbm(n2,x*.01+5,y*.01,4)*1.6+.2);
    let c=mixc(base,hex('#4b3a8e'),cl*cl*.55);c=mixc(c,hex('#2f7f95'),cl2*cl2*.35);
    const st=n2(x*1.7,y*1.7);if(st>.8)c=mixc(c,[255,255,255],(st-.8)*5);
    return c;
  });
  const r=mulberry(4);
  for(let i=0;i<26;i++){const x=r()*600,y=r()*800;glow(ctx,x,y,6+r()*8,'200,230,255',.6);ctx.fillStyle='#fff';ctx.beginPath();ctx.arc(x,y,.8+r()*.6,0,7);ctx.fill()}
  // one faint arcane ring, high up behind the panel's edge
  ctx.save();ctx.globalAlpha=.16;ctx.strokeStyle='#bfe9ff';ctx.lineWidth=1;
  for(const rad of [250,262])ctx.beginPath(),ctx.arc(300,560,rad,0,7),ctx.stroke();
  for(let i=0;i<72;i++){const a=i/72*Math.PI*2,r1=250,r2=i%6?256:268;ctx.beginPath();ctx.moveTo(300+r1*Math.cos(a),560+r1*Math.sin(a));ctx.lineTo(300+r2*Math.cos(a),560+r2*Math.sin(a));ctx.stroke()}
  ctx.restore();
}

function wall_dark(ctx){
  const n=noise2(31),n2=noise2(32),n3=noise2(33),rr_=mulberry(77);
  // Ashlar: courses of varying height, blocks of varying length, edges worn by noise.
  const rows=[];for(let y=-10;y<820;){const h=42+Math.floor(rr_()*26);const xs=[];let x=-40-rr_()*80;while(x<640){xs.push(x);x+=64+rr_()*90}xs.push(x);rows.push({y0:y,y1:y+h,xs,tone:xs.map(()=>rr_()-.5)});y+=h}
  const rowAt=new Array(820);for(const r of rows)for(let y=Math.max(0,Math.floor(r.y0));y<Math.min(820,r.y1);y++)rowAt[y]=r;
  paint(ctx,0,0,600,800,(x,y)=>{
    const r=rowAt[Math.floor(y)];let k=0;while(k<r.xs.length-2&&r.xs[k+1]<=x)k++;
    const x0=r.xs[k],x1=r.xs[k+1],wob=fbm(n3,x*.08,y*.08,3)*3.2;
    const dl=x-x0+wob,dr=x1-x+wob,dt=y-r.y0+wob,db=r.y1-y+wob,edge=Math.min(dl,dr,dt,db);
    const grain=fbm(n,x*.05,y*.05,5),big=fbm(n2,x*.008+k*1.7,y*.008+r.y0*.01,3);
    let c=mixc(hex('#1b181c'),hex('#4c464c'),clamp(.45+grain*.5+big*.45+r.tone[k]*.35));
    c=mixc(c,hex('#2e3a2c'),clamp(fbm(n3,x*.02,y*.02,3)+.1)*.22); // a little damp moss
    if(edge<1.8)c=shade(c,.22);
    else if(edge<5){const t=(edge-1.8)/3.2;c=(dt<5||dl<5)&&dt<=db?shade(c,lerp(1.3,1,t)):shade(c,lerp(.5,1,t))}
    const crack=Math.abs(fbm(n3,x*.03+9,y*.03,4));if(crack<.012)c=shade(c,.55);
    // moonlight falling from a high window on the right, in two shafts
    const u=(x*.55+y*.84),beam=Math.max(0,Math.cos((u-420)/38))**6*clamp(1-Math.abs(u-420)/260)+Math.max(0,Math.cos((u-560)/30))**6*clamp(1-Math.abs(u-560)/200)*.6;
    const fall=clamp(1-y/760);c=mixc(c,hex('#a9b8d0'),beam*fall*.42);
    const l=Math.exp(-(((x-300)/330)**2+((y-420)/380)**2));c=shade(c,.38+.75*l);
    const mist=clamp((y-540)/260)*clamp(fbm(n3,x*.006+y*.002,y*.018,4)*1.3+.5);c=mixc(c,hex('#5e5c66'),mist*.5);
    return c.map(v=>Math.min(255,v));
  });
  // a pointed arch carved behind the shelves
  const arch=()=>{ctx.beginPath();ctx.moveTo(70,800);ctx.lineTo(70,420);ctx.quadraticCurveTo(80,250,300,170);ctx.quadraticCurveTo(520,250,530,420);ctx.lineTo(530,800)};
  ctx.save();arch();ctx.closePath();ctx.fillStyle='rgba(0,0,0,.28)';ctx.fill();ctx.restore();
  ctx.lineWidth=3;arch();ctx.strokeStyle='rgba(0,0,0,.6)';ctx.stroke();
  ctx.save();ctx.translate(-2.5,-2.5);arch();ctx.strokeStyle='rgba(190,190,205,.14)';ctx.lineWidth=1.4;ctx.stroke();ctx.restore();
  ctx.save();ctx.translate(14,8);ctx.scale(.953,.99);arch();ctx.strokeStyle='rgba(0,0,0,.45)';ctx.lineWidth=2;ctx.stroke();ctx.restore();
  const vg=ctx.createRadialGradient(300,430,240,300,430,640);vg.addColorStop(0,'rgba(0,0,0,0)');vg.addColorStop(1,'rgba(0,0,0,.55)');ctx.fillStyle=vg;ctx.fillRect(0,0,600,800);
}

function wall_nouveau(ctx){
  const n=noise2(41),n2=noise2(42);
  paint(ctx,0,0,600,800,(x,y)=>{
    const f=fbm(n,x*.015,y*.015,5)*.5+fbm(n,x*.4,y*.06,2)*.12;
    let c=mixc(hex('#1f2d27'),hex('#3e5446'),clamp(.5+f));
    const l=Math.exp(-(((x-300)/360)**2+((y-360)/460)**2));c=shade(c,.62+.55*l);return c.map(v=>Math.min(255,v));
  });
  ctx.save();const pat=ctx.createPattern(nouveauTile(),'repeat');pat.setTransform(new DOMMatrix().scale(1/S));ctx.fillStyle=pat;ctx.fillRect(0,0,600,800);ctx.restore();
  // the gold frame, thin, with whiplash curls at the shoulders and a bloom at the crown
  const gold=ctx.createLinearGradient(0,0,600,800);gold.addColorStop(0,'#a07a38');gold.addColorStop(.45,'#ecd08c');gold.addColorStop(1,'#9a7434');
  ctx.strokeStyle=gold;ctx.lineWidth=1.8;ctx.lineCap='round';
  ctx.beginPath();ctx.moveTo(24,786);ctx.lineTo(24,130);ctx.bezierCurveTo(24,52,120,30,196,34);ctx.bezierCurveTo(246,38,266,20,300,16);ctx.bezierCurveTo(334,20,354,38,404,34);ctx.bezierCurveTo(480,30,576,52,576,130);ctx.lineTo(576,786);ctx.stroke();
  ctx.lineWidth=.8;ctx.globalAlpha=.7;ctx.beginPath();ctx.moveTo(31,786);ctx.lineTo(31,134);ctx.bezierCurveTo(31,62,124,40,196,43);ctx.moveTo(569,786);ctx.lineTo(569,134);ctx.bezierCurveTo(569,62,476,40,404,43);ctx.stroke();ctx.globalAlpha=1;
  for(const s of [1,-1]){const cx=s>0?24:576;ctx.lineWidth=1.6;
    ctx.beginPath();ctx.moveTo(cx,210);ctx.bezierCurveTo(cx+s*36,200,cx+s*52,160,cx+s*32,140);ctx.bezierCurveTo(cx+s*18,128,cx+s*4,142,cx+s*13,154);ctx.bezierCurveTo(cx+s*20,162,cx+s*30,154,cx+s*25,146);ctx.stroke();
    ctx.beginPath();ctx.moveTo(cx,640);ctx.bezierCurveTo(cx+s*26,632,cx+s*34,606,cx+s*20,596);ctx.bezierCurveTo(cx+s*10,590,cx+s*4,600,cx+s*10,606);ctx.stroke()}
  ctx.fillStyle=gold;ctx.save();ctx.translate(300,18);for(const a of [-.7,-.35,0,.35,.7]){ctx.save();ctx.rotate(a);ctx.beginPath();ctx.moveTo(0,0);ctx.bezierCurveTo(-5,-7,-4,-17,0,-24);ctx.bezierCurveTo(4,-17,5,-7,0,0);ctx.fill();ctx.restore()}ctx.restore();
}

function wall_deco(ctx){
  const n=noise2(51),n2=noise2(52);
  paint(ctx,0,0,600,800,(x,y)=>{
    const v=fbm(n,x*.01,y*.01,5),sheen=fbm(n2,x*.003,y*.05,3);
    let c=mixc(hex('#06140f'),hex('#174a3a'),clamp(.42+v*.6+sheen*.4));
    const l=Math.exp(-(((x-300)/300)**2+((y-60)/420)**2));c=shade(c,.5+.85*l);
    return c.map(v=>Math.min(255,v));
  });
  ctx.save();const pat=ctx.createPattern(decoTile(),'repeat');pat.setTransform(new DOMMatrix().scale(1/S));ctx.fillStyle=pat;ctx.globalAlpha=.9;ctx.fillRect(0,0,600,800);ctx.restore();
  // a darker field behind the shelves, edged in gold, stepped at the top like a skyscraper crown
  const gold=ctx.createLinearGradient(0,0,600,0);gold.addColorStop(0,'#8a6a2a');gold.addColorStop(.5,'#f6dc9a');gold.addColorStop(1,'#8a6a2a');
  const field=()=>{ctx.beginPath();ctx.moveTo(40,800);ctx.lineTo(40,330);ctx.lineTo(120,330);ctx.lineTo(120,310);ctx.lineTo(200,310);ctx.lineTo(200,292);ctx.lineTo(400,292);ctx.lineTo(400,310);ctx.lineTo(480,310);ctx.lineTo(480,330);ctx.lineTo(560,330);ctx.lineTo(560,800)};
  ctx.save();field();ctx.closePath();const fg=ctx.createLinearGradient(0,290,0,800);fg.addColorStop(0,'rgba(2,8,6,.55)');fg.addColorStop(1,'rgba(2,8,6,.8)');ctx.fillStyle=fg;ctx.fill();ctx.restore();
  ctx.strokeStyle=gold;ctx.lineWidth=1.4;field();ctx.stroke();
  ctx.save();ctx.translate(0,6);ctx.lineWidth=.6;ctx.globalAlpha=.7;ctx.beginPath();ctx.moveTo(46,800);ctx.lineTo(46,330);ctx.lineTo(126,330);ctx.lineTo(126,310);ctx.lineTo(206,310);ctx.lineTo(206,292);ctx.lineTo(394,292);ctx.lineTo(394,310);ctx.lineTo(474,310);ctx.lineTo(474,330);ctx.lineTo(554,330);ctx.lineTo(554,800);ctx.stroke();ctx.restore();
  // sunburst rising from the crown
  ctx.save();ctx.globalAlpha=.55;for(let i=0;i<=20;i++){const a=Math.PI+Math.PI*i/20;ctx.strokeStyle=gold;ctx.lineWidth=i%2?1:.5;ctx.beginPath();ctx.moveTo(300+24*Math.cos(a),292+24*Math.sin(a));ctx.lineTo(300+90*Math.cos(a),292+90*Math.sin(a));ctx.stroke()}ctx.restore();
  ctx.fillStyle=gold;ctx.beginPath();ctx.arc(300,292,18,Math.PI,0);ctx.fill();
  ctx.strokeStyle=gold;ctx.lineWidth=1.2;ctx.strokeRect(10,10,580,780);
}


// ── Planks ────────────────────────────────────────────────────────────────
// Bookshelf's plank design: 360 px tall, three bands of 120. The middle band is the plank: its top
// 96 px the top surface, its last 24 the front face. Below it, the shadow (and brackets).
const PW=960,PH=360,SURF0=120,FACE0=216,FACE1=240,CAP_W=220,CAP_END=70,K=96/22; // K: texture px per drawing unit
const PLANKS={
  academia:{seed:12,
    surf:(n,u,v)=>shade(wood(n,u,v*66,'#2e160b','#6b3a20'),.75+.35*v),
    face:(n,u,v)=>shade(wood(n,u+999,v*36,'#22100a','#4a2616'),.7),
    decor(ctx,x0,x1){ctx.fillStyle='rgba(255,220,170,.25)';ctx.fillRect(x0,FACE0-2,x1-x0,2);
      const g=ctx.createLinearGradient(0,FACE0+2,0,FACE0+7);g.addColorStop(0,'#e8c886');g.addColorStop(1,'#7a5a2a');ctx.fillStyle=g;ctx.fillRect(x0,FACE0+2,x1-x0,5)}},
  nebula:{seed:22,
    surf:(n,u,v)=>shade(wood(n,u,v*55,'#8a8fa8','#dfe2ee',.7),.72+.3*v),
    face:(n,u,v)=>shade(wood(n,u+500,v*36,'#5a5f78','#9aa0b8',.7),.62),
    decor(ctx,x0,x1){ctx.save();ctx.shadowColor='#8fe3ff';ctx.shadowBlur=18;ctx.fillStyle='#bff1ff';ctx.fillRect(x0,FACE0,x1-x0,3);ctx.restore()}},
  crypt:{seed:32,
    surf:(n,u,v)=>shade(wood(n,u,v*66,'#0d0907','#3e2e22',.8),.62+.4*v),
    face:(n,u,v)=>shade(wood(n,u+300,v*36,'#0b0806','#2a2018'),.55),
    decor(ctx,x0,x1,n){const g=ctx.createLinearGradient(0,FACE0+4,0,FACE0+18);g.addColorStop(0,'#5a5458');g.addColorStop(.5,'#2c282b');g.addColorStop(1,'#161416');
      ctx.fillStyle=g;ctx.fillRect(x0,FACE0+4,x1-x0,14);
      for(let rx=x0+40;rx<x1;rx+=96){const rg=ctx.createRadialGradient(rx-1.6,FACE0+9.6,0,rx,FACE0+11,5.2);rg.addColorStop(0,'#b4aeb2');rg.addColorStop(1,'#2a2729');ctx.fillStyle=rg;ctx.beginPath();ctx.arc(rx,FACE0+11,4.8,0,7);ctx.fill()}},
    cap(ctx){ctx.fillStyle='#1c1a1c';ctx.beginPath();ctx.moveTo(CAP_END+8,FACE1);ctx.lineTo(CAP_END+32,FACE1);ctx.lineTo(CAP_END+20,FACE1+38);ctx.closePath();ctx.fill();
      ctx.strokeStyle='rgba(160,150,155,.4)';ctx.lineWidth=1.6;ctx.beginPath();ctx.moveTo(CAP_END+8,FACE1);ctx.lineTo(CAP_END+20,FACE1+38);ctx.stroke()}},
  arabesque:{seed:42,
    surf:(n,u,v)=>shade(wood(n,u,v*66,'#5a3a1e','#a87a48',.8),.75+.3*v),
    face:(n,u,v)=>shade(wood(n,u+400,v*36,'#3e2812','#7a5430'),.7),
    decor(ctx,x0,x1){const g=ctx.createLinearGradient(0,FACE0+4,0,FACE0+20);g.addColorStop(0,'#f0d490');g.addColorStop(1,'#8a6a2a');ctx.strokeStyle=g;ctx.lineWidth=2.6;
      ctx.beginPath();for(let x=x0;x<=x1;x+=2){const y=FACE0+12+4.8*Math.sin(2*Math.PI*(x-x0)/(PW/8));x===x0?ctx.moveTo(x,y):ctx.lineTo(x,y)}ctx.stroke()},
    cap(ctx){const g=ctx.createLinearGradient(0,FACE1,0,FACE1+60);g.addColorStop(0,'#f0d490');g.addColorStop(1,'#8a6a2a');ctx.strokeStyle=g;ctx.lineWidth=6;ctx.lineCap='round';
      const bx=CAP_END+30;ctx.beginPath();ctx.moveTo(bx,FACE1);ctx.bezierCurveTo(bx,FACE1+52,bx+52,FACE1+56,bx+48,FACE1+26);ctx.bezierCurveTo(bx+44,FACE1+10,bx+22,FACE1+18,bx+30,FACE1+30);ctx.stroke()}},
  emerald:{seed:52,
    surf:(n,u,v)=>{const v2=fbm(n,u*.02,v*22*.08,4),vein=Math.pow(1-Math.abs(fbm(n,u*.006+3,v*22*.03,3)*2),14);let c=mixc(hex('#0b0b0c'),hex('#262628'),clamp(.4+v2));c=mixc(c,hex('#b0b0b4'),vein*.55);return shade(c,.8+.32*v)},
    face:()=>[5,5,5],
    decor(ctx,x0,x1){const g=ctx.createLinearGradient(0,0,PW,0);g.addColorStop(0,'#8a6a2a');g.addColorStop(.5,'#f0d590');g.addColorStop(1,'#8a6a2a');ctx.fillStyle=g;
      ctx.fillRect(x0,FACE0,x1-x0,3);ctx.fillRect(x0,FACE0+9,x1-x0,1.6);ctx.fillRect(x0,FACE0+16,x1-x0,1.6);
      for(let cx=x0+60;cx<x1;cx+=120){ctx.beginPath();ctx.moveTo(cx,FACE0+7);ctx.lineTo(cx+6,FACE0+13);ctx.lineTo(cx,FACE0+19);ctx.lineTo(cx-6,FACE0+13);ctx.closePath();ctx.fill()}},
    cap(ctx){const g=ctx.createLinearGradient(CAP_END-14,0,CAP_END+12,0);g.addColorStop(0,'#8a6a2a');g.addColorStop(.5,'#f0d590');g.addColorStop(1,'#8a6a2a');ctx.fillStyle=g;
      ctx.beginPath();ctx.moveTo(CAP_END+10,SURF0-14);ctx.lineTo(CAP_END-2,SURF0-14);ctx.lineTo(CAP_END-2,SURF0+4);ctx.lineTo(CAP_END-14,SURF0+4);ctx.lineTo(CAP_END-14,FACE1);ctx.lineTo(CAP_END+10,FACE1);ctx.closePath();ctx.fill()}},
};
function plankPixels(p,n,w,ux){ // the plank band (rows SURF0..FACE1) as RGB, ux(px) gives the texture coordinate
  const rows=FACE1-SURF0,out=new Float32Array(w*rows*3);
  for(let j=0;j<rows;j++){const py=SURF0+j;for(let i=0;i<w;i++){const u=ux(i);
    const c=py<FACE0?p.surf(n,u,(py-SURF0)/(FACE0-SURF0)):p.face(n,u,(py-FACE0)/(FACE1-FACE0));const k=(j*w+i)*3;out[k]=c[0];out[k+1]=c[1];out[k+2]=c[2]}}
  return out;
}
function plankShadow(ctx,x0,x1,a=.55){const g=ctx.createLinearGradient(0,FACE1,0,FACE1+56);g.addColorStop(0,`rgba(0,0,0,${a})`);g.addColorStop(1,'rgba(0,0,0,0)');ctx.fillStyle=g;ctx.fillRect(x0,FACE1,x1-x0,56)}
function plankMiddle(id){
  const p=PLANKS[id],n=noise2(p.seed),FADE=120,ext=plankPixels(p,n,PW+FADE,i=>i/K);
  const c=document.createElement('canvas');c.width=PW;c.height=PH;const ctx=c.getContext('2d');
  plankShadow(ctx,0,PW);
  const img=ctx.createImageData(PW,FACE1-SURF0),d=img.data,rows=FACE1-SURF0,w=PW+FADE;
  for(let j=0;j<rows;j++)for(let i=0;i<PW;i++){ // crossfade the ends: the strip repeats without a seam
    const t=i<FADE?i/FADE:1,a=(j*w+i)*3,b=(j*w+i+PW)*3,k=(j*PW+i)*4;
    for(let ch=0;ch<3;ch++)d[k+ch]=i<FADE?ext[a+ch]*t+ext[b+ch]*(1-t):ext[a+ch];d[k+3]=255}
  ctx.putImageData(img,0,SURF0);
  p.decor(ctx,0,PW,n);
  return c;
}
function plankLeft(id){
  const p=PLANKS[id],n=noise2(p.seed),w=CAP_W,rows=FACE1-SURF0,px=plankPixels(p,n,w,i=>(i-CAP_END)/K+700);
  const c=document.createElement('canvas');c.width=w;c.height=PH;const ctx=c.getContext('2d');
  // the plank, its rounded outer corners, its shadow
  const body=document.createElement('canvas');body.width=w;body.height=PH;const b=body.getContext('2d');
  plankShadow(b,CAP_END+6,w);
  const img=b.createImageData(w,rows);for(let j=0;j<rows;j++)for(let i=0;i<w;i++){const a=(j*w+i)*3,k=(j*w+i)*4;img.data[k]=px[a];img.data[k+1]=px[a+1];img.data[k+2]=px[a+2];img.data[k+3]=i>=CAP_END?255:0}
  const tmp=document.createElement('canvas');tmp.width=w;tmp.height=rows;tmp.getContext('2d').putImageData(img,0,0);
  b.save();b.beginPath();b.roundRect(CAP_END,SURF0,w,rows,[14,0,0,14]);b.clip();b.drawImage(tmp,0,SURF0);p.decor(b,CAP_END,w,n);b.restore();
  // fade into the middle piece, which lies under it
  b.globalCompositeOperation='destination-in';const f=b.createLinearGradient(110,0,w,0);f.addColorStop(0,'#000');f.addColorStop(1,'rgba(0,0,0,0)');b.fillStyle=f;b.fillRect(0,0,w,PH);
  ctx.drawImage(body,0,0);
  if(p.cap)p.cap(ctx);
  return c;
}
function mirrored(src){const c=document.createElement('canvas');c.width=src.width;c.height=src.height;const ctx=c.getContext('2d');ctx.translate(src.width,0);ctx.scale(-1,1);ctx.drawImage(src,0,0);return c}

// ── Ornaments ─────────────────────────────────────────────────────────────
// Drawn four times their drawing size on a clear canvas, cropped to what was drawn, the bottom on
// the base line with a little room under it so the piece stands back on the plank, beside the books.
const ORNAMENTS={
  academia:{'bankers-lamp':bankersLamp,'book-stack':bookStack},
  nebula:{'crystals':crystals,'potion':potion},
  crypt:{'candelabrum':candelabrum,'grimoire':grimoire},
  arabesque:{'galle-vase':galleVase,'tiffany-lamp':tiffany2},
  emerald:{'fan-lamp':fanLamp,'coupes':coupes},
};
function ornament(fn){
  const Z=4,W=360,H=320,B=280;S=Z;const c=document.createElement('canvas');c.width=W*Z;c.height=H*Z;const ctx=c.getContext('2d');ctx.scale(Z,Z);
  fn(ctx,120,B);
  const d=ctx.getImageData(0,0,c.width,B*Z).data;let x0=1e9,x1=-1,y0=1e9;
  for(let y=0;y<B*Z;y++)for(let x=0;x<c.width;x++)if(d[(y*c.width+x)*4+3]>6){if(x<x0)x0=x;if(x>x1)x1=x;if(y<y0)y0=y}
  const h=B*Z-y0,room=Math.round(h*.05),out=document.createElement('canvas');out.width=x1-x0+1;out.height=h+room;
  out.getContext('2d').drawImage(c,x0,y0,out.width,h,0,0,out.width,h);
  return out;
}

// ── Wallpapers ────────────────────────────────────────────────────────────
const WALLS={academia:wall_academia,nebula:wall_fantasy,crypt:wall_dark,arabesque:wall_nouveau,emerald:wall_deco};
function wallpaper(id){
  S=1236/600;const c=document.createElement('canvas');c.width=1236;c.height=1648;const ctx=c.getContext('2d');ctx.setTransform(S,0,0,S,0,0);WALLS[id](ctx);return c;
}

const EXPORT={on:true};
function renderTheme(id){
  const left=plankLeft(id);
  const ornaments={};for(const[name,fn]of Object.entries(ORNAMENTS[id]))ornaments[name]=ornament(fn).toDataURL('image/png');
  return {wallpaper:wallpaper(id).toDataURL('image/jpeg',.9),middle:plankMiddle(id).toDataURL('image/png'),
    left:left.toDataURL('image/png'),right:mirrored(left).toDataURL('image/png'),ornaments};
}
