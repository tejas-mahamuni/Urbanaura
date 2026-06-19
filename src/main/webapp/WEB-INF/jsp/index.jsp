<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UrbanAura | Property Explorer</title>
    <link rel="icon" type="image/png" href="/images/urbanaura-logo.png" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.6.1/sockjs.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <style>
        :root{--bg:#eef4f6;--panel:rgba(248,252,252,.88);--card:#ffffff;--text:#13252c;--muted:#5f7680;--line:rgba(19,37,44,.08);--accent:#0f9d8a;--accent-deep:#126f97;--green:#117a65;--blue:#1c78c0;--gold:#d19a2a;--red:#c85050;--shadow:0 20px 50px rgba(23,54,69,.10)}
        *{box-sizing:border-box;margin:0;padding:0;font-family:'Inter',sans-serif}
        body{min-height:100vh;color:var(--text);background:radial-gradient(circle at top left,rgba(15,157,138,.14),transparent 22%),radial-gradient(circle at 85% 20%,rgba(28,120,192,.12),transparent 24%),linear-gradient(180deg,#f4f8f9 0%,#edf3f5 100%)}
        button,input,select{font:inherit}
        .topbar{display:flex;justify-content:space-between;align-items:center;padding:16px 18px 0 18px}
        .brand{display:flex;align-items:center;gap:12px}
        .brand-mark{width:42px;height:42px;border-radius:14px;display:grid;place-items:center;background:linear-gradient(135deg,var(--accent),var(--accent-deep));color:#fff;font-weight:800;box-shadow:0 10px 22px rgba(18,111,151,.24)}
        .brand-copy strong{display:block;font-size:15px;letter-spacing:-.02em}
        .brand-copy span{display:block;font-size:12px;color:var(--muted)}
        .topbar-actions{display:flex;gap:10px;align-items:center}
        .layout{display:flex;gap:18px;min-height:calc(100vh - 74px);padding:18px}
        .feed{width:60%;display:flex;flex-direction:column;gap:18px;min-width:0}
        .map-pane{width:40%;min-width:330px;position:sticky;top:18px;height:calc(100vh - 36px);border-radius:28px;overflow:hidden;border:1px solid var(--line);background:var(--card);box-shadow:var(--shadow)}
        .surface{background:var(--panel);border:1px solid rgba(255,255,255,.62);border-radius:28px;backdrop-filter:blur(18px);box-shadow:var(--shadow)}
        .feed-shell{padding:24px}
        .hero{display:grid;grid-template-columns:54% 46%;gap:20px;min-height:100vh;align-items:stretch;padding:60px 24px 40px;box-sizing:border-box;}
        .hero h1{font-size:clamp(34px,4vw,54px);line-height:.96;letter-spacing:-.05em;margin-bottom:12px;max-width:11ch;animation:slideUpFade .8s ease-out;background:linear-gradient(135deg,#13252c,#1c78c0 58%,#0f9d8a);-webkit-background-clip:text;-webkit-text-fill-color:transparent}
        .eyebrow{display:inline-flex;padding:8px 12px;border-radius:999px;background:rgba(15,157,138,.10);color:var(--accent-deep);font-size:12px;font-weight:700;text-transform:uppercase;letter-spacing:.05em;margin-bottom:12px}
        .hero p,.copy,.drawer-copy{color:var(--muted);font-size:14px;line-height:1.7}
        .hero-stats,.metric-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px;margin-top:18px}
        .stat{padding:14px;border-radius:18px;border:1px solid var(--line);background:rgba(255,255,255,.68)}
        .metric-box{padding:14px;border-radius:18px;background:linear-gradient(135deg,rgba(235,250,248,.88),rgba(242,252,255,.94));border:1px solid rgba(15,157,138,.18);box-shadow:0 4px 12px rgba(15,157,138,.04)}
        .stat strong,.metric-box strong{display:block;font-size:18px;margin-bottom:4px}
        .stat span,.metric-box span{font-size:12px;color:var(--muted)}
        .hero-side {
            position: relative;
            border-radius: 24px;
            padding: 40px !important;
            background: linear-gradient(135deg, rgba(15,157,138,0.05), rgba(15,157,138,0.12)) !important;
            border: 1px solid rgba(15,157,138,0.18);
            backdrop-filter: blur(10px);
            box-shadow: inset 0 2px 8px rgba(255,255,255,0.4), 0 20px 40px rgba(0,0,0,0.05);
            color: #163744;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: space-between;
            text-align: center;
            min-height: 360px;
            overflow: hidden;
            z-index: 1;
        }
        .hero-side h3 { color: #163744; margin-bottom: 12px; margin-top: 24px; font-weight: 800; letter-spacing: -0.02em; }
        .hero-side p { color: var(--muted); margin-bottom: 24px; font-weight: 500; }
        .hero-logo-container { width: 100%; flex-grow: 1; display: flex; align-items: center; justify-content: center; margin-bottom: 20px; overflow: visible; }
        @keyframes float { 0% { transform: translateY(0px) scale(2.2); } 50% { transform: translateY(-6px) scale(2.2); } 100% { transform: translateY(0px) scale(2.2); } }
        .side-hero-logo { width: 100%; height: 200px; object-fit: contain; opacity: 0.95; filter: drop-shadow(0 10px 20px rgba(15,157,138,0.15)); animation: float 4s ease-in-out infinite; transform: scale(2.2); transform-origin: center; }
        .button-outline { flex: 1; padding: 12px 24px; border-radius: 999px; color: var(--accent-deep); cursor: pointer; font-weight: 700; border: 1px solid rgba(15,157,138,0.3); background: rgba(255,255,255,0.6); backdrop-filter: blur(6px); transition: background 0.3s ease, border-color 0.3s ease; text-align: center; display: inline-block; }
        .button-outline:hover { background: #fff; border-color: rgba(15,157,138,0.6); }
        .hero-cta{display:flex;gap:12px;align-items:center;margin-top:18px}
        .hero-kicker{font-size:13px;color:var(--muted);max-width:34ch}
        .hero-map-card{display:flex;flex-direction:column;justify-content:space-between;height:100%;position:relative;z-index:1}
        .live-badge{display:inline-flex;align-items:center;gap:8px;padding:9px 12px;border-radius:999px;background:rgba(255,255,255,.14);font-size:12px;font-weight:700;align-self:flex-start}
        .live-dot{width:8px;height:8px;border-radius:50%;background:#ff6b6b;box-shadow:0 0 0 6px rgba(255,107,107,.18)}
        .map-mini{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px}
        .map-mini .stat{background:rgba(255,255,255,.12);border-color:rgba(255,255,255,.14);color:#fff}
        .map-mini .stat span{color:rgba(235,247,249,.76)}
        .row,.feed-head,.card-head,.card-actions,.filter-form,.drawer-actions{display:flex;flex-wrap:wrap;gap:10px;align-items:center}
        .feed-head{justify-content:space-between;align-items:flex-start}
        .feed-head h2{font-size:30px;letter-spacing:-.04em;margin-bottom:6px}
        .pill,.chip{display:inline-flex;align-items:center;gap:6px;padding:8px 12px;border-radius:999px;font-size:12px;font-weight:600}
        .pill{background:rgba(19,37,44,.06);color:var(--muted)}
        .chip{border:none;cursor:pointer}
        .green{background:rgba(23,120,89,.12);color:var(--green)}
        .blue{background:rgba(45,110,166,.11);color:var(--blue)}
        .gold{background:rgba(201,166,107,.18);color:var(--gold)}
        .red{background:rgba(183,72,60,.12);color:var(--red)}
        .btn,.btn-alt{padding:11px 18px;border-radius:999px;cursor:pointer;font-weight:600;transition:transform .2s cubic-bezier(.34,1.56,.64,1),box-shadow .2s ease}
        .btn{border:none;color:#fff;background:linear-gradient(135deg,var(--accent),var(--accent-deep));box-shadow:0 12px 26px rgba(18,111,151,.24)}
        .btn:hover{transform:translateY(-2px) scale(1.03);box-shadow:0 16px 30px rgba(18,111,151,.32)}
        .btn:active{transform:translateY(1px) scale(.96)}
        .btn-alt{border:1px solid var(--line);background:rgba(255,255,255,.74);color:var(--text)}
        .btn-alt:hover{background:#fff;border-color:rgba(28,120,192,.24)}
        .search-pill{min-width:180px;padding:12px 14px;border-radius:14px;border:1px solid var(--line);background:rgba(255,255,255,.86);outline:none;transition:all .3s ease}
        .search-pill:focus{background:#fff;border-color:var(--accent);box-shadow:0 0 0 4px rgba(15,157,138,.12)}
        .property-list{display:flex;flex-direction:column;gap:18px;margin-top:18px}
        @keyframes slideUpFade{0%{opacity:0;transform:translateY(30px) scale(.98)}100%{opacity:1;transform:translateY(0) scale(1)}}
        @keyframes floatBreath{0%,100%{transform:translateY(0);box-shadow:0 8px 32px rgba(0,0,0,.08)}50%{transform:translateY(-8px);box-shadow:0 16px 42px rgba(15,157,138,.20)}}
        .property-card{display:grid;grid-template-columns:290px minmax(0,1fr);gap:18px;padding:16px;border-radius:26px;border:1px solid rgba(19,37,44,.06);background:linear-gradient(180deg,rgba(255,255,255,.96),rgba(246,252,252,.94));box-shadow:0 14px 32px rgba(23,54,69,.06);cursor:pointer;transition:all .35s cubic-bezier(.25,.8,.25,1);animation:slideUpFade .6s cubic-bezier(.16,1,.3,1) both}
        .property-card:hover{transform:translateY(-6px) scale(1.01);box-shadow:0 26px 50px rgba(23,54,69,.12);border-color:rgba(15,157,138,.24)}
        .visual{min-height:238px;border-radius:20px;padding:18px;color:#fff;display:flex;flex-direction:column;justify-content:space-between;background:linear-gradient(145deg,rgba(16,27,34,.18),rgba(16,27,34,.52)),linear-gradient(135deg,#18a999,#1c78c0 58%,#163744);transition:transform .5s cubic-bezier(.21,1.02,.73,1);position:relative;overflow:hidden}
        .visual::after{content:"";position:absolute;right:-40px;bottom:-50px;width:160px;height:160px;border-radius:50%;background:radial-gradient(circle,rgba(255,255,255,.22),transparent 70%)}
        .property-card:hover .visual{transform:scale(1.02)}
        .media-row{display:flex;justify-content:space-between;gap:10px}
        .media-pill{padding:8px 10px;border-radius:14px;background:rgba(255,255,255,.16);font-size:12px;font-weight:600}
        .visual strong{display:block;font-size:32px;letter-spacing:-.05em}
        .visual span{display:block;width:18ch;color:rgba(255,255,255,.82);font-size:13px;line-height:1.5}
        .info{display:flex;flex-direction:column;justify-content:space-between;gap:16px;min-width:0}
        .title{font-size:27px;font-weight:700;line-height:1.04;letter-spacing:-.04em;margin-bottom:8px}
        .sub{color:var(--muted);font-size:14px;line-height:1.5}
        .price{margin-left:auto;text-align:right;font-size:34px;font-weight:800;letter-spacing:-.05em;white-space:nowrap;color:#0f3240}
        .price span{display:block;margin-top:4px;font-size:11px;color:var(--muted);text-transform:uppercase;letter-spacing:.05em}
        .price-line{display:flex;justify-content:space-between;align-items:flex-start;gap:18px;margin:10px 0 12px}
        .price-copy{font-size:13px;color:var(--muted);line-height:1.6;max-width:36ch}
        .badge-top{display:inline-flex;align-items:center;gap:6px;padding:7px 10px;border-radius:999px;background:rgba(15,157,138,.12);color:var(--accent-deep);font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.05em}
        .summary-row{display:flex;justify-content:space-between;align-items:flex-end;gap:14px}
        .action-group{display:flex;gap:10px;align-items:center;flex-wrap:wrap}
        .btn-secondary-inline{padding:10px 14px;border-radius:999px;border:1px solid rgba(19,37,44,.10);background:#fff;color:var(--text);font-weight:600;cursor:pointer}
        .aqi-chip-moderate{background:rgba(209,154,42,.16);color:#9a6d12}
        .aqi-chip-good{background:rgba(17,122,101,.12);color:#117a65}
        .aqi-chip-poor{background:rgba(200,80,80,.12);color:#b53d3d}
        .insight{display:grid;grid-template-columns:90px minmax(0,1fr);gap:14px;align-items:center}
        .ring,.drawer-ring{border-radius:50%;position:relative;display:grid;place-items:center;background:conic-gradient(var(--accent) 0deg,var(--accent) var(--angle),rgba(19,37,44,.08) var(--angle))}
        .ring{width:90px;height:90px}
        .drawer-ring{width:116px;height:116px;margin:0 auto 16px}
        .ring::before,.drawer-ring::before{content:"";position:absolute;border-radius:50%;background:var(--card)}
        .ring::before{width:66px;height:66px}
        .drawer-ring::before{width:84px;height:84px}
        .ring > div,.drawer-ring > div{position:relative;z-index:1;display:flex;flex-direction:column;align-items:center;justify-content:center;width:100%}
        .ring strong,.drawer-ring strong,.ring span,.drawer-ring span{display:block;width:100%;text-align:center}
        .ring strong{color:var(--accent-deep);font-weight:800;font-size:13px;line-height:1}
        .drawer-ring strong{color:#123746;font-weight:700;font-size:24px;line-height:1}
        .ring span,.drawer-ring span{display:block;font-size:10px;color:var(--muted);text-transform:uppercase;letter-spacing:.05em}
        .ring span{font-size:7px;line-height:1.05;margin-top:2px;letter-spacing:.08em}
        .drawer-ring span{display:block;margin-top:5px;font-weight:600;font-size:9px;letter-spacing:.08em}
        #map{width:100%;height:100%;background:#deedf1}
        .map-overlay{position:absolute;inset:18px 18px auto 18px;z-index:1000;display:flex;justify-content:space-between;gap:12px;pointer-events:none}
        .map-note{pointer-events:auto;padding:12px 14px;border-radius:16px;background:rgba(249,253,253,.90);border:1px solid var(--line);box-shadow:0 10px 24px rgba(23,54,69,.08)}
        .map-note strong{display:block;font-size:13px;margin-bottom:4px}
        .map-note span{font-size:12px;color:var(--muted)}
        .leaflet-popup-content-wrapper,.leaflet-popup-tip{background:rgba(250,254,255,.96);color:var(--text);box-shadow:0 12px 26px rgba(23,54,69,.14)}
        .leaflet-popup-content{margin:10px 12px;font-size:13px;line-height:1.4}
        .aura-marker{position:relative;width:30px;height:30px}
        .marker-pin{width:14px;height:14px;background:var(--accent);border-radius:50%;border:2px solid #fff;position:absolute;top:8px;left:8px;z-index:2}
        .pulse{width:30px;height:30px;border-radius:50%;background:var(--accent);opacity:0;position:absolute;top:0;left:0}
        .marker-glow .pulse{animation:pulseGlow 1.5s ease-out infinite}
        @keyframes pulseGlow{0%{transform:scale(.6);opacity:.8}100%{transform:scale(2);opacity:0}}
        .backdrop{position:fixed;inset:0;background:rgba(13,24,31,.24);opacity:0;pointer-events:none;transition:opacity .25s ease;z-index:1700}
        .backdrop.open{opacity:1;pointer-events:auto}
        .drawer{position:fixed;top:0;right:-500px;width:460px;max-width:calc(100vw - 18px);height:100vh;padding:24px;overflow-y:auto;background:rgba(246,251,252,.97);backdrop-filter:blur(24px);box-shadow:-18px 0 42px rgba(23,54,69,.16);z-index:1800;transition:right .45s cubic-bezier(.16,1,.3,1)}
        .drawer.open{right:0}
        .drawer-top{display:flex;justify-content:space-between;gap:18px;align-items:flex-start;margin-bottom:18px}
        .drawer-top > div:first-child{flex:1;min-width:0;padding-right:8px}
        .drawer-top h3{font-size:24px;line-height:1.04;letter-spacing:-.035em;margin-bottom:6px;max-width:11ch}
        .drawer-top .drawer-copy{font-size:12px;line-height:1.45}
        .drawer-price{text-align:right;font-size:24px;font-weight:800;color:var(--accent-deep);letter-spacing:-.025em;line-height:1.02;max-width:120px;flex-shrink:0}
        #detailPrice{margin-top:64px;max-width:none;white-space:nowrap;font-size:28px}
        .drawer-price span{display:block;font-size:11px;color:var(--muted);text-transform:uppercase;letter-spacing:.04em;margin-top:6px;font-weight:600}
        .close{position:absolute;top:20px;right:20px;width:42px;height:42px;border-radius:50%;border:1px solid rgba(19,37,44,.10);background:rgba(255,255,255,.92);cursor:pointer;font-size:22px;font-weight:500;color:#23414d;display:grid;place-items:center;box-shadow:0 8px 20px rgba(23,54,69,.10);transition:transform .18s ease,box-shadow .18s ease,background .18s ease;z-index:2}
        .close:hover{transform:translateY(-1px) scale(1.03);background:#ffffff;box-shadow:0 12px 24px rgba(23,54,69,.14)}
        .drawer-hero{padding:22px;border-radius:22px;color:#fff;background:linear-gradient(165deg,#163744,#1c78c0 50%,#0f9d8a);margin-bottom:18px}
        .drawer-hero p{color:rgba(236,249,250,.82)}
        .drawer-section{border:1px solid rgba(15,157,138,.16);border-radius:20px;background:linear-gradient(160deg,rgba(247,253,254,.94),rgba(252,255,255,.96));padding:18px;margin-bottom:16px;box-shadow:0 6px 16px rgba(15,157,138,.03)}
        .section-label{font-size:12px;text-transform:uppercase;letter-spacing:.08em;color:var(--muted);margin-bottom:10px}
        .aqi-status{display:inline-flex;align-items:center;gap:8px;padding:8px 12px;border-radius:999px;font-size:12px;font-weight:700;margin:10px 0 4px 0}
        .aqi-status.good{background:rgba(0,0,0,.25);color:#5cf0a9;border:1px solid rgba(92,240,169,.3)}
        .aqi-status.moderate{background:rgba(0,0,0,.25);color:#f7d774;border:1px solid rgba(247,215,116,.3)}
        .aqi-status.poor{background:rgba(0,0,0,.25);color:#fd8787;border:1px solid rgba(253,135,135,.3)}
        .drawer-overview-grid{display:grid;grid-template-columns:1.2fr .8fr;gap:12px;margin-top:16px}
        .drawer-stack-metrics{display:grid;gap:12px}
        .drawer-lead-metric{padding:16px 18px;border-radius:18px;background:rgba(255,255,255,.16);border:1px solid rgba(255,255,255,.18)}
        .drawer-lead-metric strong{display:block;font-size:22px}
        .drawer-lead-metric span{display:block;font-size:12px;color:rgba(236,249,250,.78)}
        .amenity-list{display:grid;gap:10px;list-style:none}
        .amenity-item{display:flex;justify-content:space-between;gap:12px;padding:14px 16px;border-radius:16px;background:linear-gradient(135deg,rgba(235,250,248,.88),rgba(242,252,255,.94));border:1px solid rgba(15,157,138,.18);box-shadow:0 4px 12px rgba(15,157,138,.04)}
        .amenity-item strong{display:block;font-size:14px;margin-bottom:2px}
        .amenity-item span,.amenity-item small{color:var(--muted)}
        .chat-bubble-btn{position:fixed;right:30px;bottom:30px;width:56px;height:56px;border-radius:50%;background:rgba(248,252,252,.94);border:1px solid var(--line);box-shadow:0 8px 32px rgba(0,0,0,.08);display:flex;justify-content:center;align-items:center;cursor:pointer;z-index:1500;color:var(--accent);font-size:22px;animation:floatBreath 3s ease-in-out infinite;transition:all .3s cubic-bezier(.34,1.56,.64,1)}
        .chat-bubble-btn:hover{transform:scale(1.15) rotate(5deg);background:linear-gradient(135deg,var(--accent),var(--accent-deep));color:#fff;border-color:transparent;animation-play-state:paused}
        .chat-window{display:none;position:fixed;right:30px;bottom:104px;width:360px;height:490px;background:rgba(248,252,252,.97);border-radius:24px;border:1px solid var(--line);box-shadow:0 24px 64px rgba(23,54,69,.18);z-index:1500;overflow:hidden;opacity:0;transform:translateY(30px) scale(0.95);transition:all .4s cubic-bezier(.16,1,.3,1);flex-direction:column}
        .chat-window.active{display:flex;opacity:1;transform:translateY(0) scale(1)}
        .chat-header{padding:16px 20px;background:rgba(183,92,54,.06);border-bottom:1px solid var(--line);display:flex;justify-content:space-between;font-weight:600}
        .chat-history{flex:1;padding:20px;overflow-y:auto;display:flex;flex-direction:column;gap:12px;font-size:14px}
        .chat-msg { max-width: 85%; padding: 12px 16px; border-radius: 18px; line-height: 1.5; white-space: pre-wrap; font-size: 14px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
        .msg-ai { background: rgba(0,0,0,0.05); align-self: flex-start; border-bottom-left-radius: 4px; }
        .msg-user { background: linear-gradient(135deg, var(--accent), var(--accent-deep)); color: #fff; align-self: flex-end; border-bottom-right-radius: 4px; }
        
        .chat-list-item { padding: 16px 20px; border-bottom: 1px solid var(--line); cursor: pointer; transition: all 0.2s; border-left: 4px solid transparent; }
        .chat-list-item:hover { background: #f8fbfb; }
        .chat-list-item.active { background: #f0f7f7; border-left-color: var(--accent); }
        .chat-list-item.unread { background: rgba(15,157,138,0.06); border-left-color: rgba(15,157,138,0.5); }
        .chat-list-item.unread .fw-bold { color: var(--accent) !important; }
        .chat-avatar { width: 40px; height: 40px; border-radius: 50%; background: linear-gradient(135deg, var(--accent), var(--accent-deep)); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 16px; flex-shrink: 0; }
        .chat-message { max-width: 85%; padding: 12px 16px; border-radius: 18px; margin-bottom: 12px; font-size: 14px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); line-height: 1.5;}
        .chat-message.sent { background: linear-gradient(135deg, var(--accent), var(--accent-deep)); color: #fff; align-self: flex-end; border-bottom-right-radius: 4px; }
        .chat-message.received { background: #ffffff; border: 1px solid rgba(19,37,44,0.1); color: var(--text); align-self: flex-start; border-bottom-left-radius: 4px; }
        
        #userHubDrawer { right: -850px; width: 800px; max-width: 95vw; padding: 0; }
        #userHubDrawer.open { right: 0; }
        @media (max-width: 850px) {
            #userHubDrawer { width: 100%; right: -100%; }
        }
        
        .typing span{animation:blink 1.4s infinite both;font-size:24px;line-height:0.5;margin:0 1px}
        .typing span:nth-child(2){animation-delay:0.2s}
        .typing span:nth-child(3){animation-delay:0.4s}
        @keyframes blink{0%{opacity:.2}20%{opacity:1}100%{opacity:.2}}
        .chat-input-area{padding:16px;border-top:1px solid var(--line);display:flex;gap:8px}
        .chat-input-area input{flex:1;padding:12px 16px;border:1px solid var(--line);border-radius:999px;outline:none;background:rgba(255,255,255,.6)}
        .chat-input-area button{width:42px;height:42px;border:none;border-radius:50%;cursor:pointer;color:#fff;background:linear-gradient(135deg,var(--accent),var(--accent-deep))}
        .compare-tray{position:fixed;left:50%;bottom:30px;transform:translate(-50%,140px) scale(.92);display:flex;align-items:center;gap:20px;padding:12px 14px 12px 24px;border-radius:999px;background:rgba(16,27,34,.86);border:1px solid rgba(15,157,138,.45);box-shadow:0 0 38px rgba(15,157,138,.40),0 18px 48px rgba(16,27,34,.50);backdrop-filter:blur(24px) saturate(180%);-webkit-backdrop-filter:blur(24px) saturate(180%);z-index:1650;transition:all .55s cubic-bezier(.34,1.56,.64,1);opacity:0;pointer-events:none}
        .compare-tray.open{transform:translate(-50%,0) scale(1);opacity:1;pointer-events:auto}
        .compare-copy strong{display:block;font-size:15px;letter-spacing:-.02em;color:#ffffff;white-space:nowrap}
        .compare-copy span{display:none}
        .compare-tray .drawer-actions{flex-wrap:nowrap}
        .compare-picks{display:flex;gap:8px;align-items:center;border-left:1px solid rgba(255,255,255,.15);padding-left:18px;margin-left:4px}
        .compare-pill{display:flex;align-items:center;gap:6px;padding:8px 14px;border-radius:999px;background:rgba(15,157,138,.20);color:#ffffff;font-size:13px;font-weight:700;border:1px solid rgba(15,157,138,.35)}
        .compare-pill button{border:none;background:transparent;color:rgba(255,255,255,.6);cursor:pointer;font-size:18px;line-height:.8;transition:transform .2s;display:grid;place-items:center}
        .compare-pill button:hover{transform:scale(1.2) rotate(90deg);color:#ff6b6b}
        .compare-tray .btn{box-shadow:0 8px 24px rgba(15,157,138,.3);animation:comparePulse 2s infinite ease-in-out}
        @keyframes comparePulse{0%,100%{box-shadow:0 8px 24px rgba(15,157,138,.3)}50%{box-shadow:0 12px 32px rgba(15,157,138,.5);transform:translateY(-1px)}}
        .compare-drawer{position:fixed;left:50%;top:50%;width:min(1080px,calc(100vw - 32px));max-height:calc(100vh - 42px);padding:24px;border-radius:28px;background:rgba(246,251,252,.98);border:1px solid rgba(19,37,44,.10);box-shadow:0 30px 70px rgba(23,54,69,.22);transform:translate(-50%,-48%) scale(.96);opacity:0;pointer-events:none;z-index:1850;transition:transform .28s ease,opacity .28s ease;overflow:auto}
        .compare-drawer.open{transform:translate(-50%,-50%) scale(1);opacity:1;pointer-events:auto}
        .compare-head{display:flex;justify-content:space-between;gap:14px;align-items:flex-start;margin-bottom:18px}
        .compare-head h3{font-size:28px;letter-spacing:-.04em;margin-bottom:6px}
        .compare-grid{display:grid;grid-template-columns:220px repeat(3,minmax(0,1fr));gap:12px;min-width:780px}
        .compare-label,.compare-cell{padding:14px 16px;border-radius:18px;border:1px solid var(--line)}
        .compare-label{background:rgba(19,37,44,.04);font-size:12px;font-weight:700;text-transform:uppercase;letter-spacing:.06em;color:var(--muted)}
        .compare-cell{background:#fff}
        .compare-cell strong{display:block;font-size:14px;margin-bottom:4px}
        .compare-cell span{font-size:12px;color:var(--muted);line-height:1.45}
        .compare-cell.featured{background:linear-gradient(180deg,rgba(15,157,138,.10),rgba(255,255,255,.98));border-color:rgba(15,157,138,.18)}
        .compare-topline{display:flex;justify-content:space-between;gap:10px;align-items:flex-start}
        .compare-topline em{font-style:normal;font-size:22px;font-weight:800;letter-spacing:-.04em;color:#0f3240}
        .compare-empty{padding:30px;border-radius:22px;border:1px dashed rgba(19,37,44,.18);text-align:center;color:var(--muted);background:rgba(255,255,255,.62)}
        @media (max-width:1180px){.layout{flex-direction:column}.feed,.map-pane{width:100%}.map-pane{position:relative;top:0;height:420px}.hero{grid-template-columns:1fr}.drawer{width:100%;max-width:100%}.property-card{grid-template-columns:1fr}.drawer-overview-grid{grid-template-columns:1fr}
            .header-logo { height: 45px; }
            .hero-logo { height: 70px; }
            .side-hero-logo { height: 70px; }
            .hero-side { padding: 40px !important; }
        }
        @media (max-width:760px){.topbar{padding:12px 12px 0 12px}.layout{padding:12px;gap:12px}.hero,.feed-shell{padding:18px}.hero-stats,.metric-grid,.map-mini{grid-template-columns:1fr}.card-head,.feed-head,.drawer-top,.price-line,.summary-row,.compare-head,.compare-tray{flex-direction:column;align-items:flex-start}.price,.drawer-price{text-align:left;max-width:none}.chat-window{right:12px;left:12px;width:auto}.chat-bubble-btn{right:12px;bottom:12px}.compare-tray{left:12px;right:12px;transform:translateY(180px) scale(.92);border-radius:24px;padding:18px}.compare-tray.open{transform:translateY(0) scale(1)}.compare-picks{border-left:none;padding-left:0;margin-left:0;flex-wrap:wrap}.compare-drawer{width:calc(100vw - 16px);padding:18px}.compare-grid{min-width:620px}
            .header-logo { height: 40px; }
            .brand-copy span { display: none; }
            .side-hero-logo { height: 60px; }
            .hero-side { padding: 30px !important; }
            .hero-actions { flex-direction: column; }
        }
        .header-logo { height: 50px; object-fit: contain; cursor: pointer; border-radius: 8px; }
        .hero-logo { height: 80px; object-fit: contain; cursor: pointer; display: block; margin-bottom: 24px; border-radius: 12px; }
    </style>
</head>
<body>
<div class="topbar">
    <div class="brand">
        <div class="brand-mark">UA</div>
        <div class="brand-copy">
            <strong>UrbanAura Pune</strong>
            <span>Smart city discovery for home decisions</span>
        </div>
    </div>
    <div class="topbar-actions">
        <c:choose>
            <c:when test="${isAuthenticated}">
                <c:choose>
                    <c:when test="${username == 'admin'}">
                        <a href="/admin/dashboard" style="text-decoration:none;">
                            <button type="button" class="btn" style="background:linear-gradient(135deg, #0f9d8a, #0c8272); color:#fff; border:none; padding:8px 16px; border-radius:999px; font-weight:700; box-shadow:0 4px 12px rgba(15,157,138,0.3);">
                                Admin Dashboard
                            </button>
                        </a>
                    </c:when>
                    <c:otherwise>
                        <span class="pill" style="font-weight:600; cursor:pointer; border: 1px solid rgba(15,157,138,0.3); background: #f0f7f7; color: var(--accent-deep);" onclick="openUserHub()">My Chats</span>
                        <span class="pill" style="font-weight:600;">Signed in as <c:out value="${username}"/></span>
                    </c:otherwise>
                </c:choose>
                <form action="/logout" method="post" style="margin:0;">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                    <button type="submit" class="btn" style="border-radius:999px;">Sign Out</button>
                </form>
            </c:when>
            <c:otherwise>
                <a href="/login" style="text-decoration:none;"><button type="button" class="btn">Sign In</button></a>
            </c:otherwise>
        </c:choose>
    </div>
</div>
<div class="layout">
    <section class="feed">
        <section class="hero surface">
            <div style="display: flex; flex-direction: column; justify-content: center; gap: 14px; padding-right: 20px; height: 100%;">
                <div>
                    <span class="eyebrow" style="margin-bottom: 4px;">SMART CITY DISCOVERY</span>
                </div>
                
                <h1 style="margin-bottom: 0; max-width: 500px; line-height: 1.15; font-size: clamp(28px, 3.5vw, 42px);">
                    <span style="font-weight: 800; display: block;">Explore neighborhoods,</span>
                    <span style="font-weight: 800; display: block;"><span style="color: var(--accent-deep);">compare</span> homes</span>
                    <span style="font-weight: 500; display: block; font-size: 0.85em; color: var(--text);">with <span style="color: var(--accent-deep);">live</span> city insights.</span>
                </h1>
                
                <p style="font-size: 15px; margin-bottom: 0; color: var(--muted);">Live AQI, safety, and connectivity built into every listing.</p>
                
                <div style="display: flex; flex-direction: column; gap: 6px; margin-top: 4px;">
                    <div style="display: flex; gap: 10px; align-items: center;">
                        <button type="button" class="btn" style="padding: 10px 20px; font-size: 15px;" onclick="document.querySelector('.feed-shell').scrollIntoView({behavior:'smooth'})">Start Exploring</button>
                        <button type="button" class="btn-alt" style="padding: 10px 20px; font-size: 15px;" onclick="document.querySelector('.feed-shell').scrollIntoView({behavior:'smooth'})">Compare Properties</button>
                    </div>
                    <span style="font-size: 11px; color: var(--muted); padding-left: 10px; font-weight: 500;">No sign-in needed to explore</span>
                </div>
                
                <div style="display: flex; gap: 16px; font-size: 13px; font-weight: 600; color: var(--text); margin-top: 4px; flex-wrap: nowrap; white-space: nowrap;">
                    <span style="display: flex; align-items: center; gap: 6px;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="var(--accent)" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg> Live AQI</span>
                    <span style="display: flex; align-items: center; gap: 6px;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="var(--accent)" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg> Smart score</span>
                    <span style="display: flex; align-items: center; gap: 6px;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="var(--accent)" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg> AI insights</span>
                </div>
                
                <div class="hero-stats" style="margin-top: 6px; gap: 8px;">
                    <div class="stat" style="padding: 12px 18px;">
                        <strong style="font-size: 24px; font-weight: 800; letter-spacing: -0.04em; margin-bottom: 0;">${properties.size()}</strong>
                        <span style="font-size: 10px; text-transform: uppercase; letter-spacing: 0.05em; display: block; margin-top: 2px;">Homes</span>
                    </div>
                    <div class="stat" style="padding: 12px 18px;">
                        <strong style="font-size: 24px; font-weight: 800; letter-spacing: -0.04em; margin-bottom: 0;">930</strong>
                        <span style="font-size: 10px; text-transform: uppercase; letter-spacing: 0.05em; display: block; margin-top: 2px;">Records</span>
                    </div>
                    <div class="stat" style="padding: 12px 18px;">
                        <strong style="font-size: 24px; font-weight: 800; letter-spacing: -0.04em; color: var(--accent-deep); margin-bottom: 0;">Live</strong>
                        <span style="font-size: 10px; text-transform: uppercase; letter-spacing: 0.05em; display: block; margin-top: 2px;">AQI + AI</span>
                    </div>
                </div>
            </div>
            <div class="hero-side">
                <div class="hero-logo-container">
                    <img src="/images/logo.png" alt="UrbanAura Primary Logo" class="side-hero-logo">
                </div>
                <div class="hero-text">
                    <h3>Discover first. Inspect with context.</h3>
                    <p>The map stays supportive while the core experience moves into rich property cards, locality cues, and a detail drawer built for comparison.</p>
                </div>
                <div style="margin-top: auto; z-index: 2; padding: 12px 24px; background: rgba(255,255,255,0.7); border-radius: 999px; border: 1px solid rgba(15,157,138,0.2); backdrop-filter: blur(8px);">
                    <span style="font-weight: 700; color: var(--accent-deep); font-size: 14px;">Live preview &bull; Explore + Compare</span>
                </div>
            </div>
        </section>

        <section class="feed-shell surface">
            <div class="feed-head">
                <div>
                    <h2>Discover Pune Homes</h2>
                    <p>Explore listings, compare livability signals, and jump into deeper locality intelligence from the same screen.</p>
                </div>
                <form action="/" method="GET" class="filter-form">
                    <select name="filterLocalityId" class="search-pill">
                        <option value="">All Regions</option>
                        <c:forEach var="loc" items="${localities}"><option value="${loc.id}"><c:out value="${loc.name}"/></option></c:forEach>
                    </select>
                    <button type="submit" class="btn">Discover</button>
                </form>
            </div>

            <div class="row">
                <c:if test="${isAdmin}">
                    <span class="pill green">Admin tools enabled</span>
                    <a href="/admin/report/generate" target="_blank" style="text-decoration:none;"><button class="btn">Download SDG 11 Report</button></a>
                </c:if>
                <c:if test="${not isAuthenticated}"><span class="pill">Sign in to unlock the live Aura pulse and AI guide.</span></c:if>
            </div>

            <div class="property-list">
                <c:choose>
                    <c:when test="${empty properties}">
                        <p class="copy">No properties found in this region.</p>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="prop" items="${properties}" varStatus="loop">
                            <div class="property-card" style="position: relative; height: 420px; overflow: hidden; animation-delay: calc(${loop.index} * 0.05s);" role="button" tabindex="0" onclick="openPropertyDetails(this)" onkeydown="handleCardKeydown(event,this)"
                                 data-id="<c:out value="${prop.id}"/>" data-title="<c:out value="${prop.title}"/>" data-price="<c:out value="${prop.price}"/>"
                                 data-locality="<c:out value="${prop.localityName}"/>" data-aura="<c:out value="${prop.auraScore}"/>" data-smart="<c:out value="${prop.smartScore}"/>"
                                 data-green="<c:out value="${prop.greenIndex}"/>" data-safety="<c:out value="${prop.safetyRating}"/>" data-noise="<c:out value="${prop.noiseLevelDb}"/>"
                                 data-park="<c:out value="${prop.parkDist}"/>" data-metro="<c:out value="${prop.metroDist}"/>" data-hospital="<c:out value="${prop.hospitalDist}"/>"
                                 data-aqi="<c:out value="${prop.latestAqi}"/>" data-pm25="<c:out value="${prop.latestPm25}"/>" data-blinkit="<c:out value="${prop.blinkitDist}"/>"
                                 data-blinkit-label="<c:out value="${prop.nearestBlinkit}"/>" data-amazon="<c:out value="${prop.amazonDist}"/>" data-flipkart="<c:out value="${prop.flipkartDist}"/>"
                                 data-maintenance="<c:out value="${prop.maintenanceMonthly}"/>">
                                <c:set var="extImg" value="${loop.index % 2 == 0 ? '/images/ext.png' : '/images/ext2.png'}" />
                                <c:set var="intImg" value="${loop.index % 2 == 0 ? '/images/int.png' : '/images/int2.png'}" />
                                
                                <div class="card-carousel" style="position:absolute; inset:0; height:100%; display:flex; overflow-x:auto; scroll-snap-type:x mandatory; scrollbar-width:none; z-index:1;">
                                    <div style="min-width:100%; height:100%; scroll-snap-align:start; position: relative;">
                                        <img src="${extImg}" alt="Exterior View" style="width:100%; height:100%; object-fit:cover;">
                                        <span style="position: absolute; top: 16px; right: 16px; background: rgba(0,0,0,0.5); color: #fff; padding: 4px 10px; border-radius: 999px; font-size: 11px; font-weight: 600; backdrop-filter: blur(4px);">Exterior &nbsp;&rarr;</span>
                                    </div>
                                    <div style="min-width:100%; height:100%; scroll-snap-align:start; position: relative;">
                                        <img src="${intImg}" alt="Interior View" style="width:100%; height:100%; object-fit:cover;">
                                        <span style="position: absolute; top: 16px; right: 16px; background: rgba(0,0,0,0.5); color: #fff; padding: 4px 10px; border-radius: 999px; font-size: 11px; font-weight: 600; backdrop-filter: blur(4px);">Interior &nbsp;&rarr;</span>
                                    </div>
                                    <div style="min-width:100%; height:100%; scroll-snap-align:start; position: relative;">
                                        <img src="/images/plan.png" alt="Floor Plan" style="width:100%; height:100%; object-fit:cover;">
                                        <span style="position: absolute; top: 16px; right: 16px; background: rgba(0,0,0,0.5); color: #fff; padding: 4px 10px; border-radius: 999px; font-size: 11px; font-weight: 600; backdrop-filter: blur(4px);">Plan</span>
                                    </div>
                                </div>
                                
                                <div class="info" style="position:absolute; bottom:0; left:0; right:0; z-index:2; padding: 80px 24px 24px; background: linear-gradient(to top, rgba(10,25,30,0.95) 0%, rgba(10,25,30,0.8) 40%, transparent 100%); color: #fff; pointer-events: none;">
                                    <div style="display:flex; justify-content:space-between; align-items:flex-end; margin-bottom:16px; pointer-events: auto;">
                                        <div style="flex:1; padding-right:16px;">
                                            <div class="title" style="font-size:24px; font-weight:800; margin-bottom:6px; line-height:1.2; letter-spacing:-0.02em; color: #fff;"><c:out value="${prop.title}"/></div>
                                            <div class="sub" style="font-size:15px; font-weight:500; color: rgba(255,255,255,0.7);"><c:out value="${prop.localityName}"/></div>
                                        </div>
                                        <div class="ring" style="--angle:${prop.auraScore * 3.6}deg; flex-shrink:0; transform:scale(1); transform-origin:bottom right; background: conic-gradient(var(--accent) 0deg, var(--accent) var(--angle), rgba(255,255,255,0.1) var(--angle));">
                                            <div style="background: rgba(10,25,30,0.9); border-radius: 50%; width: 66px; height: 66px; display: flex; flex-direction: column; align-items: center; justify-content: center;">
                                                <strong style="margin-bottom:2px; font-size:16px; color: #fff;"><c:out value="${prop.auraScore}"/></strong><span style="font-size:9px; color: rgba(255,255,255,0.7);">Aura</span>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; pointer-events: auto;">
                                        <div class="price" style="text-align:left; font-size:26px; font-weight:800; color: #00ffcc; letter-spacing:-0.03em; margin: 0;">
                                            Rs. <c:out value="${prop.price}"/> Cr
                                        </div>
                                        <div style="font-size:13px; font-weight:600; color: rgba(255,255,255,0.9); display:flex; gap: 12px;">
                                            <span style="display:flex; align-items:center; gap:4px;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#0f9d8a" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg> <c:choose><c:when test="${not empty prop.safetyRating}"><c:out value="${prop.safetyRating}"/></c:when><c:otherwise>N/A</c:otherwise></c:choose>/10</span>
                                            <span style="display:flex; align-items:center; gap:4px;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#0f9d8a" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M9.59 4.59A2 2 0 1 1 11 8H2m10.59 11.41A2 2 0 1 0 14 16H2m15.73-8.27A2.5 2.5 0 1 1 19.5 12H2"></path></svg> <c:choose><c:when test="${not empty prop.latestAqi}"><c:out value="${prop.latestAqi}"/></c:when><c:otherwise>N/A</c:otherwise></c:choose></span>
                                        </div>
                                    </div>

                                    <div class="action-group" style="display:flex; gap:12px; pointer-events: auto;">
                                        <button type="button" class="btn" style="flex:1; justify-content:center; padding:12px; font-size:14px; background: rgba(255,255,255,0.1); backdrop-filter: blur(8px); border: 1px solid rgba(255,255,255,0.2); color: #fff;" onclick="openPropertyDetailsFromChip(event,this)">View Details</button>
                                        <button type="button" class="btn-secondary-inline" style="flex:1; justify-content:center; padding:12px; font-size:14px; background: rgba(255,255,255,0.9); border: none; color: var(--text);" onclick="openCompare(event,this)">Compare</button>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>
    </section>

    <aside class="map-pane">
        <div class="map-overlay">
            <div class="map-note"><strong>Explore Map</strong><span>Contextual, live, and intentionally secondary.</span></div>
            <div class="map-note"><strong>Aura Pulse</strong><span>Markers react when AQI updates arrive.</span></div>
        </div>
        <div id="map"></div>
    </aside>
</div>

<div id="detailBackdrop" class="backdrop" onclick="closeDrawer()"></div>
<aside id="detailDrawer" class="drawer" aria-hidden="true">
    <div class="drawer-top">
        <div>
            <div class="eyebrow" style="margin-bottom:10px;">Discovery Panel</div>
            <h3 id="detailTitle">Property Name</h3>
            <p id="detailSubtitle" class="drawer-copy">Pune locality snapshot</p>
        </div>
        <div>
            <button type="button" class="close" onclick="closeDrawer()" aria-label="Close details">&times;</button>
            <div id="detailPrice" class="drawer-price">Rs. 0 Cr<span>Guided asking price</span></div>
        </div>
    </div>
    <section class="drawer-hero">
        <div class="section-label" style="color:rgba(236,249,250,.70);margin-bottom:6px;">Overview</div>
        <div class="drawer-overview-grid">
            <div>
                <div class="drawer-ring" id="detailAuraRing" style="--angle:0deg;"><div><strong id="detailAuraScore">0</strong><span>Aura Score</span></div></div>
                <p id="detailAuraCopy">Live livability confidence built from smart metrics and the latest AQI context.</p>
                <div id="detailAqiStatus" class="aqi-status moderate">AQI status pending</div>
            </div>
            <div class="drawer-stack-metrics">
                <div class="drawer-lead-metric"><strong id="detailSmartScore">0</strong><span>Primary Smart Score</span></div>
                <div class="drawer-lead-metric"><strong id="detailGreenIndex">0</strong><span>SDG 11 Green Index</span></div>
            </div>
        </div>
    </section>
    <section class="drawer-section">
        <div class="section-label">Live Environment</div>
        <div class="metric-grid">
            <div class="metric-box"><strong id="detailAqi">N/A</strong><span>Latest AQI</span></div>
            <div class="metric-box"><strong id="detailPm25">N/A</strong><span>PM2.5</span></div>
            <div class="metric-box"><strong id="detailNoise">N/A</strong><span>Noise Level</span></div>
            <div class="metric-box"><strong id="detailSafety">N/A</strong><span>Safety Rating</span></div>
        </div>
    </section>
    <section class="drawer-section">
        <div class="section-label">What's Nearby</div>
        <ul class="amenity-list">
            <li class="amenity-item"><div><strong>Schools</strong><small>Top rated educational institutes</small></div><span>3 within 2km</span></li>
            <li class="amenity-item"><div><strong>Hospitals</strong><small>Emergency medical care</small></div><span id="detailHospitalCopy">2 nearby</span></li>
            <li class="amenity-item"><div><strong>Stores</strong><small>Quick commerce delivery</small></div><span id="detailStoresCopy">Blinkit, Amazon active</span></li>
        </ul>
    </section>
    <section class="drawer-section">
        <div class="section-label">Hyper-local Connectivity</div>
        <ul id="amenitiesList" class="amenity-list"></ul>
    </section>
    <section class="drawer-section">
        <div class="section-label">Smart Scores</div>
        <div class="metric-grid">
            <div class="metric-box"><strong id="detailCommuteScore">N/A</strong><span>Commute Friendliness</span></div>
            <div class="metric-box"><strong id="detailConvenienceScore">N/A</strong><span>Convenience Score</span></div>
            <div class="metric-box"><strong id="detailMaintenanceScore">N/A</strong><span>Maintenance Signal</span></div>
            <div class="metric-box"><strong id="detailHealthScore">N/A</strong><span>Health Access</span></div>
        </div>
    </section>
    <section class="drawer-section">
        <div class="section-label">Operations</div>
        <div class="drawer-actions">
            <button type="button" class="btn" onclick="openBookingFromDrawer()">Book a Visit</button>
            <button type="button" class="btn" style="background: linear-gradient(135deg, #25D366, #128C7E);" onclick="openChatFromDrawer()">Chat with Owner</button>
            <button type="button" class="btn-secondary-inline" onclick="compareSelectedProperty()">Compare with nearby properties</button>
            <c:if test="${isAdmin}"><a href="/admin/report/generate" target="_blank" style="text-decoration:none;"><button type="button" class="btn-alt">Open Admin Report</button></a></c:if>
        </div>
        <p id="detailOperationsCopy" class="drawer-copy" style="margin-top:12px;">Pick a home to inspect its locality signature before taking action.</p>
    </section>
</aside>

<div id="bookingBackdrop" class="backdrop" style="z-index:1900" onclick="closeBookingModal()"></div>
<aside id="bookingDrawer" class="drawer" style="z-index:2000" aria-hidden="true">
    <div class="drawer-top">
        <div><div class="eyebrow" style="margin-bottom:10px;">Visit Request</div><h3 id="bookingPropertyTitle">Schedule a site visit</h3></div>
        <button type="button" class="close" onclick="closeBookingModal()" aria-label="Close booking">&times;</button>
    </div>
    <section class="drawer-section">
        <div class="section-label">Your Details</div>
        <div style="display:grid;gap:12px;">
            <input type="text" id="bookingName" placeholder="Full name" class="search-pill" required>
            <input type="email" id="bookingEmail" placeholder="Email address" class="search-pill" required>
            <input type="tel" id="bookingPhone" placeholder="Phone number" class="search-pill" required>
            <input type="text" id="bookingMessage" placeholder="Preferred date or request details" class="search-pill">
        </div>
        <div class="drawer-actions" style="margin-top:16px;">
            <button type="button" class="btn" onclick="submitBooking()">Submit Request</button>
            <button type="button" class="btn-alt" onclick="closeBookingModal()">Cancel</button>
        </div>
    </section>
</aside>

<div id="compareTray" class="compare-tray" aria-hidden="true">
    <div class="compare-copy">
        <strong>Comparison ready</strong>
        <span>Select up to 3 homes, then compare price, aura, connectivity, and environment side by side.</span>
    </div>
    <div id="comparePicks" class="compare-picks"></div>
    <div class="drawer-actions">
        <button type="button" class="btn" onclick="openCompareDrawer()">Compare Now</button>
        <button type="button" class="btn-alt" onclick="clearCompare()">Clear</button>
    </div>
</div>

<div id="compareBackdrop" class="backdrop" onclick="closeCompareDrawer()"></div>
<section id="compareDrawer" class="compare-drawer" aria-hidden="true">
    <div class="compare-head">
        <div>
            <div class="eyebrow" style="margin-bottom:10px;">Comparison Studio</div>
            <h3>Compare nearby homes with decision-grade context.</h3>
            <p class="copy">Use this panel to inspect price, aura, AQI, and commute signals before choosing which listing deserves a visit.</p>
        </div>
        <button type="button" class="close" onclick="closeCompareDrawer()" aria-label="Close comparison">&times;</button>
    </div>
    <div id="compareContent" class="compare-empty">Pick at least two properties to open side-by-side comparison.</div>
</section>

<div id="ownerChatBackdrop" class="backdrop" style="z-index:2100" onclick="closeUserHub()"></div>
<aside id="userHubDrawer" class="drawer" style="z-index:2200; display:flex; flex-direction:column;" aria-hidden="true">
    <div style="display:flex; flex:1; min-height:0;">
        <!-- Left Pane: Chat List -->
        <div style="width: 320px; border-right: 1px solid var(--line); display:flex; flex-direction:column; background: #fff; flex-shrink: 0;">
            <div style="padding: 24px; border-bottom: 1px solid var(--line);">
                <div class="eyebrow" style="margin-bottom:10px;">Communications</div>
                <h3 style="font-size:24px; letter-spacing:-0.035em;">My Chats</h3>
            </div>
            <div id="userChatList" style="flex:1; overflow-y:auto; background: #fafdfd;">
            </div>
        </div>
        <!-- Right Pane: Active Chat -->
        <div style="flex:1; display:flex; flex-direction:column; background: rgba(246,251,252,0.5);">
            <div style="padding: 24px; border-bottom: 1px solid var(--line); display:flex; justify-content:space-between; align-items:center; background: #fff;">
                <div>
                    <h3 id="chatPropTitle" style="font-size:20px; margin-bottom:4px;">Select a conversation</h3>
                    <div id="chatAdminName" style="font-size:13px; color:var(--muted);"></div>
                </div>
                <button type="button" class="close" style="position:static;" onclick="closeUserHub()" aria-label="Close chat">&times;</button>
            </div>
            <div id="userMessagesContainer" style="flex-grow:1; overflow-y:auto; padding: 24px; display:flex; flex-direction:column; gap:10px;">
                <div style="text-align:center; font-size:12px; color:var(--muted); margin-top: auto; margin-bottom: auto;">Select a chat from the left to start messaging.</div>
            </div>
            <div style="flex-shrink:0; padding: 16px 24px; border-top:1px solid var(--line); display:flex; gap:10px; background: #fff;">
                <input type="text" id="userMessageInput" class="search-pill" style="flex-grow:1;" placeholder="Type reply..." disabled onkeypress="if(event.key === 'Enter') document.getElementById('userSendBtn').click();">
                <button id="userSendBtn" class="btn" style="padding: 12px 18px;" disabled onclick="sendUserChat()">Send</button>
            </div>
        </div>
    </div>
</aside>

<c:if test="${isAuthenticated}">
    <button class="chat-bubble-btn" type="button" onclick="toggleChatWindow()">AI</button>
    <div id="chatWindow" class="chat-window">
        <div class="chat-header"><span>UrbanAura Guide</span><button type="button" class="close" onclick="toggleChatWindow()">&times;</button></div>
        <div id="chatHistory" class="chat-history"><div class="chat-msg msg-ai">Ask about a Pune locality, compare two neighborhoods, or explore which home feels strongest on livability.</div></div>
        <form class="chat-input-area" onsubmit="sendChatMessage(event)"><input type="text" id="chatInput" placeholder="Try: compare Kothrud and Baner for livability"><button type="submit">Go</button></form>
    </div>
</c:if>
<script>
    const csrfHeader='<c:out value="${_csrf.headerName}"/>'; const csrfToken='<c:out value="${_csrf.token}"/>'; const chatEnabled=${isAuthenticated ? 'true' : 'false'}; const propertyMarkers={}; const coordinateUsage={}; let selectedPropertyElement=null; let map; let stompClient=null; const compareSelection=[];
    function n(v){if(v===undefined||v===null||v===''||v==='null')return null;const p=Number(v);return Number.isNaN(p)?null:p}
    function t(v,f){return v&&v!=='null'&&v!==''?v:f}
    function m(v){const x=n(v);return x===null?null:Math.round(x)+' m'}
    function fx(v,d){const x=n(v);return x===null?'N/A':x.toFixed(d)}
    function dataOf(el){const d=el.dataset;return{id:t(d.id,''),title:t(d.title,'Property'),price:fx(d.price,2),priceValue:n(d.price),locality:t(d.locality,'Pune'),aura:n(d.aura),smart:n(d.smart),green:n(d.green),safety:n(d.safety),noise:n(d.noise),park:n(d.park),metro:n(d.metro),hospital:n(d.hospital),aqi:n(d.aqi),pm25:n(d.pm25),blinkit:n(d.blinkit),blinkitLabel:t(d.blinkitLabel,'Nearest Blinkit hub'),amazon:n(d.amazon),flipkart:n(d.flipkart),maintenance:n(d.maintenance)}}
    function aqiStatus(aqi){if(aqi===null)return {label:'AQI status pending',klass:'moderate'};if(aqi<=80)return {label:'AQI '+aqi.toFixed(1)+' - Good',klass:'good'};if(aqi<=120)return {label:'AQI '+aqi.toFixed(1)+' - Moderate',klass:'moderate'};return {label:'AQI '+aqi.toFixed(1)+' - Poor',klass:'poor'}}
    function scoreText(value){return value===null?'N/A':value.toFixed(0)+'/100'}
    function compareCell(v,label,featured){return '<div class="compare-cell'+(featured?' featured':'')+'"><strong>'+v+'</strong><span>'+label+'</span></div>'}
    function compareDisplay(v,suffix,decimals){return v===null?'N/A':v.toFixed(decimals)+(suffix||'')}
    function setCompareButtons(){
        document.querySelectorAll('.property-card').forEach(function(card){
            const btn=card.querySelector('.btn-secondary-inline');
            if(!btn)return;
            const active=compareSelection.some(function(item){return item.id===card.dataset.id;});
            btn.textContent=active?'Added':'Compare';
            btn.classList.toggle('btn',active);
            btn.classList.toggle('btn-secondary-inline',!active);
        });
    }
    function renderCompareTray(){
        const tray=document.getElementById('compareTray');
        const picks=document.getElementById('comparePicks');
        if(compareSelection.length===0){
            tray.classList.remove('open');
            tray.setAttribute('aria-hidden','true');
            picks.innerHTML='';
            setCompareButtons();
            return;
        }
        tray.classList.add('open');
        tray.setAttribute('aria-hidden','false');
        picks.innerHTML=compareSelection.map(function(item){
            return '<div class="compare-pill">'+item.locality+'<button type="button" onclick="removeCompareById(\''+item.id+'\')">&times;</button></div>';
        }).join('');
        setCompareButtons();
    }
    function removeCompareById(id){
        const idx=compareSelection.findIndex(function(item){return item.id===id;});
        if(idx>=0)compareSelection.splice(idx,1);
        renderCompareTray();
        renderCompareDrawer();
    }
    function clearCompare(){
        compareSelection.length=0;
        renderCompareTray();
        closeCompareDrawer();
    }
    function toggleCompare(card){
        if(!card)return;
        const data=dataOf(card);
        const idx=compareSelection.findIndex(function(item){return item.id===data.id;});
        if(idx>=0){
            compareSelection.splice(idx,1);
        }else{
            if(compareSelection.length===3)compareSelection.shift();
            compareSelection.push(data);
        }
        renderCompareTray();
        renderCompareDrawer();
        if(compareSelection.length===3 && idx===-1){openCompareDrawer();}
    }
    function compareRow(label,items,formatter){
        const cells=items.map(function(item,index){
            const value=formatter(item);
            const featured=index===0;
            return compareCell(value.value,value.label,featured);
        }).join('');
        return '<div class="compare-label">'+label+'</div>'+cells;
    }
    function rankedCompareItems(){
        return compareSelection.slice().sort(function(a,b){
            return (b.aura||-1)-(a.aura||-1);
        });
    }
    function renderCompareDrawer(){
        const target=document.getElementById('compareContent');
        if(compareSelection.length<2){
            target.className='compare-empty';
            target.innerHTML='Pick at least two properties to open side-by-side comparison.';
            return;
        }
        const items=rankedCompareItems();
        while(items.length<3){
            items.push({title:'Open slot',locality:'Add another property',price:'--',priceValue:null,aura:null,smart:null,green:null,aqi:null,pm25:null,safety:null,noise:null,park:null,metro:null,hospital:null,blinkit:null,maintenance:null,isPlaceholder:true});
        }
        const html='<div class="compare-grid">'
            +'<div class="compare-label">Listing</div>'
            +items.map(function(item,index){
                if(item.isPlaceholder)return '<div class="compare-cell"><strong>Open slot</strong><span>Select one more listing from the explorer.</span></div>';
                return '<div class="compare-cell'+(index===0?' featured':'')+'"><div class="compare-topline"><div><strong>'+item.title+'</strong><span>'+item.locality+', Pune</span></div><em>Rs. '+item.price+' Cr</em></div></div>';
            }).join('')
            +compareRow('Aura',items,function(item){return {value:item.isPlaceholder?'--':compareDisplay(item.aura,'',1),label:'Primary livability signal'};})
            +compareRow('AQI',items,function(item){return {value:item.isPlaceholder?'--':aqiStatus(item.aqi).label,label:'Live air quality status'};})
            +compareRow('Smart Score',items,function(item){return {value:item.isPlaceholder?'--':compareDisplay(item.smart,'',2),label:'Structured metric score'};})
            +compareRow('Green Index',items,function(item){return {value:item.isPlaceholder?'--':compareDisplay(item.green,'',2),label:'SDG 11 score'};})
            +compareRow('Noise',items,function(item){return {value:item.isPlaceholder?'--':(item.noise===null?'N/A':Math.round(item.noise)+' dB'),label:'Neighborhood sound profile'};})
            +compareRow('Safety',items,function(item){return {value:item.isPlaceholder?'--':(item.safety===null?'N/A':Math.round(item.safety)+'/10'),label:'Resident safety signal'};})
            +compareRow('Metro',items,function(item){return {value:item.isPlaceholder?'--':(m(item.metro)||'N/A'),label:'Transit reach'};})
            +compareRow('Park',items,function(item){return {value:item.isPlaceholder?'--':(m(item.park)||'N/A'),label:'Green access'};})
            +compareRow('Hospital',items,function(item){return {value:item.isPlaceholder?'--':(m(item.hospital)||'N/A'),label:'Emergency reach'};})
            +compareRow('Blinkit',items,function(item){return {value:item.isPlaceholder?'--':(m(item.blinkit)||'N/A'),label:item.blinkitLabel||'Convenience delivery'};})
            +compareRow('PM2.5',items,function(item){return {value:item.isPlaceholder?'--':compareDisplay(item.pm25,'',1),label:'Fine particulate load'};})
            +compareRow('Maintenance',items,function(item){return {value:item.isPlaceholder?'--':(item.maintenance===null?'N/A':'Rs. '+item.maintenance.toFixed(0)+'/mo'),label:'Monthly upkeep estimate'};})
            +'</div>';
        target.className='';
        target.innerHTML=html;
    }
    function openCompareDrawer(){
        renderCompareDrawer();
        document.getElementById('compareBackdrop').classList.add('open');
        document.getElementById('compareDrawer').classList.add('open');
    }
    function closeCompareDrawer(){
        document.getElementById('compareBackdrop').classList.remove('open');
        document.getElementById('compareDrawer').classList.remove('open');
    }
    function amenityHtml(d){
        const rawItems=[
            ['Green access',m(d.park),'Distance to nearest park'],
            ['Metro reach',m(d.metro),'Nearest metro connection'],
            ['Hospital access',m(d.hospital),'Emergency reach window'],
            ['Blinkit delivery',m(d.blinkit),d.blinkitLabel],
            ['Amazon access',m(d.amazon),'Last-mile e-commerce reach'],
            ['Flipkart access',m(d.flipkart),'Additional delivery coverage'],
            ['Maintenance',d.maintenance!==null?'Rs. '+d.maintenance.toFixed(0)+'/mo':null,'Monthly upkeep estimate']
        ];
        const items=rawItems.filter(function(i){return i[1]!==null;});
        if(items.length===0){
            return '<li class=\"amenity-item\"><div><strong>Connectivity data sync pending</strong><small>Smart metrics are not yet available for this listing.</small></div><span>--</span></li>';
        }
        return items.map(function(i){return '<li class=\"amenity-item\"><div><strong>'+i[0]+'</strong><small>'+i[2]+'</small></div><span>'+i[1]+'</span></li>';}).join('');
    }
    function openPropertyDetails(el){selectedPropertyElement=el;const d=dataOf(el);const aqiMeta=aqiStatus(d.aqi);const commute=((d.metro!==null?Math.max(0,100-(d.metro/15)):null));const convenience=((d.blinkit!==null?Math.max(0,100-(d.blinkit/8)):null));const health=((d.hospital!==null?Math.max(0,100-(d.hospital/15)):null));const maintenanceSignal=(d.maintenance!==null?Math.max(0,100-(d.maintenance/120)):null);document.getElementById('detailTitle').textContent=d.title;document.getElementById('detailSubtitle').textContent=d.locality+', Pune - Smart-city livability profile';document.getElementById('detailPrice').innerHTML='Rs. '+d.price+' Cr<span>Guided asking price</span>';document.getElementById('detailAuraScore').textContent=d.aura!==null?d.aura.toFixed(2):'0.00';document.getElementById('detailSmartScore').textContent=d.smart!==null?d.smart.toFixed(2):'N/A';document.getElementById('detailGreenIndex').textContent=d.green!==null?d.green.toFixed(2):'N/A';document.getElementById('detailAqi').textContent=d.aqi!==null?d.aqi.toFixed(1):'N/A';document.getElementById('detailPm25').textContent=d.pm25!==null?d.pm25.toFixed(1):'N/A';document.getElementById('detailNoise').textContent=d.noise!==null?Math.round(d.noise)+' dB':'N/A';document.getElementById('detailSafety').textContent=d.safety!==null?Math.round(d.safety)+'/10':'N/A';document.getElementById('detailCommuteScore').textContent=scoreText(commute);document.getElementById('detailConvenienceScore').textContent=scoreText(convenience);document.getElementById('detailMaintenanceScore').textContent=scoreText(maintenanceSignal);document.getElementById('detailHealthScore').textContent=scoreText(health);document.getElementById('detailAuraRing').style.setProperty('--angle',(Math.max(0,Math.min(100,d.aura||0))*3.6)+'deg');document.getElementById('detailAqiStatus').className='aqi-status '+aqiMeta.klass;document.getElementById('detailAqiStatus').textContent=aqiMeta.label;
document.getElementById('detailHospitalCopy').textContent=d.hospital!==null?Math.round(d.hospital)+'m away':'2 nearby';
let activeStores=[];if(d.blinkit!==null)activeStores.push('Blinkit');if(d.amazon!==null)activeStores.push('Amazon');if(d.flipkart!==null)activeStores.push('Flipkart');
document.getElementById('detailStoresCopy').textContent=activeStores.length>0?activeStores.join(', ')+' active':'Coverage pending';
document.getElementById('detailAuraCopy').textContent=d.aqi!==null?'Latest AQI in '+d.locality+' is '+d.aqi.toFixed(1)+'. Aura adjusts the smart score with live environmental conditions.':'Aura is currently using structured smart metrics for '+d.locality+' because no fresh AQI heartbeat is available yet.';document.getElementById('detailOperationsCopy').textContent='Use this view to compare '+d.title+' against other Pune listings before booking a site visit or exporting an admin report.';document.getElementById('amenitiesList').innerHTML=amenityHtml(d);document.getElementById('detailBackdrop').classList.add('open');document.getElementById('detailDrawer').classList.add('open')}
    function openPropertyDetailsFromChip(e,btn){e.stopPropagation();openPropertyDetails(btn.closest('.property-card'))}
    function closeDrawer(){document.getElementById('detailBackdrop').classList.remove('open');document.getElementById('detailDrawer').classList.remove('open')}
    function handleCardKeydown(e,el){if(e.key==='Enter'||e.key===' '){e.preventDefault();openPropertyDetails(el)}}
    function openBookingFromDrawer(){const title=selectedPropertyElement?selectedPropertyElement.dataset.title:'this property';document.getElementById('bookingPropertyTitle').textContent='Schedule a site visit for '+title;document.getElementById('bookingBackdrop').classList.add('open');document.getElementById('bookingDrawer').classList.add('open')}
    function closeBookingModal(){document.getElementById('bookingBackdrop').classList.remove('open');document.getElementById('bookingDrawer').classList.remove('open')}
    function submitBooking(){const title=selectedPropertyElement?selectedPropertyElement.dataset.title:'the selected property';alert('Visit request captured for '+title+'.');closeBookingModal()}
    function openCompare(e,btn){if(e)e.stopPropagation();toggleCompare(btn.closest('.property-card'))}
    function compareSelectedProperty(){if(selectedPropertyElement)toggleCompare(selectedPropertyElement);if(compareSelection.length>=2){openCompareDrawer();}else{renderCompareTray();closeDrawer();}}
    function toggleChatWindow(){if(!chatEnabled)return;document.getElementById('chatWindow').classList.toggle('active')}
    function addMsg(c,type){const h=document.getElementById('chatHistory');if(!h)return;const d=document.createElement('div');d.className='chat-msg '+(type==='user'?'msg-user':'msg-ai');if(type==='user')d.textContent=c;else d.innerHTML=c.replace(/\*\*(.*?)\*\*/g,'<strong>$1</strong>');h.appendChild(d);h.scrollTop=h.scrollHeight}
    async function sendChatMessage(e){e.preventDefault();const input=document.getElementById('chatInput');if(!input||!input.value.trim())return;const q=input.value.trim();addMsg(q,'user');input.value='';const h=document.getElementById('chatHistory');const t=document.createElement('div');t.className='chat-msg msg-ai typing';t.id='typingBubble';t.innerHTML='<span>.</span><span>.</span><span>.</span>';h.appendChild(t);h.scrollTop=h.scrollHeight;try{const r=await fetch('/ai/consult',{method:'POST',headers:{'Content-Type':'application/json',[csrfHeader]:csrfToken},body:JSON.stringify({query:q})});const data=await r.json();const el=document.getElementById('typingBubble');if(el)el.remove();addMsg(data.response||'UrbanAura AI did not return a response.','ai')}catch(err){const el=document.getElementById('typingBubble');if(el)el.remove();addMsg('UrbanAura AI is currently unavailable.','ai')}}
    function initMap(){map=L.map('map',{zoomControl:false}).setView([18.5204,73.8567],11);L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',{attribution:'&copy; OpenStreetMap contributors &copy; CARTO'}).addTo(map);L.control.zoom({position:'bottomright'}).addTo(map);const bounds=[];<c:forEach var="prop" items="${mapProperties}"><c:if test="${not empty prop.latitude and not empty prop.longitude}">(function(){const baseLat=${prop.latitude};const baseLng=${prop.longitude};const localityKey='<c:out value="${prop.localityName}"/>';const coordinateKey=baseLat.toFixed(5)+','+baseLng.toFixed(5);const usageCount=coordinateUsage[coordinateKey]||0;coordinateUsage[coordinateKey]=usageCount+1;const angle=usageCount*0.9;const radius=usageCount===0?0:0.0022*Math.ceil(usageCount/4);const adjustedLat=baseLat+(radius*Math.cos(angle));const adjustedLng=baseLng+(radius*Math.sin(angle));const icon=L.divIcon({html:'<div class="aura-marker"><span class="pulse"></span><span class="marker-pin"></span></div>',className:'',iconSize:[30,30],iconAnchor:[15,15]});const marker=L.marker([adjustedLat,adjustedLng],{icon:icon}).addTo(map);marker.bindPopup('<strong><c:out value="${prop.title}"/></strong><br><c:out value="${prop.localityName}"/><br>Aura <c:out value="${prop.auraScore}"/>');marker.on('mouseover',function(){marker.openPopup()});marker.on('mouseout',function(){marker.closePopup()});marker.on('click',function(){const card=document.querySelector('.property-card[data-id="<c:out value="${prop.id}"/>"]');if(card)openPropertyDetails(card)});if(!propertyMarkers[localityKey]){propertyMarkers[localityKey]=[]}propertyMarkers[localityKey].push(marker);bounds.push([adjustedLat,adjustedLng]);})();</c:if></c:forEach>if(bounds.length>1){map.fitBounds(bounds,{padding:[36,36]})}}
    function initAqiSocket(){if(!chatEnabled)return;const socket=new SockJS('/ws-aura');stompClient=Stomp.over(socket);stompClient.debug=null;stompClient.connect({},function(){stompClient.subscribe('/topic/aqi',function(message){try{const payload=JSON.parse(message.body);const markers=propertyMarkers[payload.locality]||[];markers.forEach(function(marker){if(marker&&marker._icon){marker._icon.classList.add('marker-glow');setTimeout(function(){if(marker._icon)marker._icon.classList.remove('marker-glow')},1800)}})}catch(err){console.error('AQI parse failed',err)}})})}
    document.addEventListener('DOMContentLoaded',function(){initMap();initAqiSocket();renderCompareTray();});
    document.addEventListener('keydown',function(e){if(e.key==='Escape'){closeDrawer();closeBookingModal();closeCompareDrawer();if(window.closeUserHub)window.closeUserHub()}});
</script>

<script type="module">
    import wsManager from '/js/websocket.js';
    
    window.openChatFromDrawer = function() {
        if(!selectedPropertyElement) return;
        const d = dataOf(selectedPropertyElement);
        openUserHub();
        loadChat(1, d.id, 'admin', d.title);
    };
    
    window.openUserHub = function() {
        document.getElementById('ownerChatBackdrop').classList.add('open');
        document.getElementById('userHubDrawer').classList.add('open');
        if (chatEnabled) fetchRecent();
    };

    window.closeUserHub = function() {
        document.getElementById('ownerChatBackdrop').classList.remove('open');
        document.getElementById('userHubDrawer').classList.remove('open');
    };

    const currentUserName = '<c:out value="${username}"/>';
    const currentUserId = <c:out value="${currentUserId != null ? currentUserId : -1}"/>;
    let currentAdminId = null;
    let currentPropertyId = null;
    let conversations = {};

    if (chatEnabled) {
        wsManager.connect(currentUserName, () => {
            console.log("User connected to socket for chat");
            fetchRecent();
        });

        wsManager.onMessageReceived((msg) => {
            if ((msg.senderId == currentAdminId && msg.propertyId == currentPropertyId) || (msg.senderId === currentUserId)) {
                appendUserMessage(msg.content, msg.senderId === currentUserId ? 'sent' : 'received');
            }
            fetchRecent();
        });
    }

    function fetchRecent() {
        conversations = {};
        fetch('/api/messages/recent')
            .then(r => r.json())
            .then(data => {
                const chatList = document.getElementById('userChatList');
                chatList.innerHTML = '';
                
                data.forEach(msg => {
                    const otherUserId = msg.senderId === currentUserId ? msg.receiverId : msg.senderId;
                    const otherUserName = msg.senderId === currentUserId ? 'Owner/Admin' : msg.senderName;
                    const key = otherUserId + '-' + msg.propertyId;
                    
                    if (!conversations[key]) {
                        conversations[key] = msg;
                        const div = document.createElement('div');
                        const isUnread = (!msg.read && msg.senderId !== currentUserId);
                        div.className = 'chat-list-item' + (isUnread ? ' unread' : '');
                        div.id = 'chat-item-' + otherUserId + '-' + msg.propertyId;
                        div.innerHTML = 
                            '<div class="d-flex gap-3 align-items-center" style="display:flex; gap:12px; align-items:center;">' +
                                '<div class="chat-avatar" style="background:#13252c;">O</div>' +
                                '<div style="flex:1; min-width:0;">' +
                                    '<div style="display:flex; justify-content:space-between; align-items:center;">' +
                                        '<div class="fw-bold" style="font-size:15px; color:var(--text); font-weight:bold;">' + otherUserName + (isUnread ? '<span style="display:inline-block; width:8px; height:8px; background:var(--accent); border-radius:50%; margin-left:8px;"></span>' : '') + '</div>' +
                                    '</div>' +
                                    '<div class="text-truncate mt-1" style="font-size:12px; color:var(--accent-deep); font-weight:600; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">' + msg.propertyTitle + '</div>' +
                                    '<div class="text-muted mt-1 text-truncate" style="font-size:13px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;' + (isUnread ? 'font-weight:600; color:var(--text) !important;' : 'color:var(--muted);') + '">' + (msg.senderId === currentUserId ? 'You: ' : '') + msg.content + '</div>' +
                                '</div>' +
                            '</div>';
                        div.onclick = () => loadChat(otherUserId, msg.propertyId, otherUserName, msg.propertyTitle);
                        chatList.appendChild(div);
                    }
                });
            });
    }

    window.loadChat = function(adminId, propertyId, adminName, propertyTitle) {
        currentAdminId = adminId;
        currentPropertyId = propertyId;
        
        document.querySelectorAll('#userChatList .chat-list-item').forEach(el => el.classList.remove('active'));
        const activeItem = document.getElementById('chat-item-' + adminId + '-' + propertyId);
        if (activeItem) activeItem.classList.add('active');

        document.getElementById('chatAdminName').innerText = 'with ' + adminName;
        document.getElementById('chatPropTitle').innerText = propertyTitle;
        
        document.getElementById('userMessageInput').disabled = false;
        document.getElementById('userSendBtn').disabled = false;
        
        fetch('/api/messages/history?userId=' + adminId + '&propertyId=' + propertyId)
            .then(r => r.json())
            .then(data => {
                const container = document.getElementById('userMessagesContainer');
                container.innerHTML = '';
                
                const secureMsg = document.createElement('div');
                secureMsg.style.textAlign = 'center';
                secureMsg.style.fontSize = '12px';
                secureMsg.style.color = 'var(--muted)';
                secureMsg.style.marginBottom = '16px';
                secureMsg.innerHTML = 'End-to-end encrypted chat started';
                container.appendChild(secureMsg);

                data.forEach(msg => {
                    appendUserMessage(msg.content, msg.senderId === currentUserId ? 'sent' : 'received');
                });
            });
    };

    window.appendUserMessage = function(content, type) {
        const container = document.getElementById('userMessagesContainer');
        const msgDiv = document.createElement('div');
        msgDiv.className = 'chat-message ' + type;
        msgDiv.textContent = content;
        container.appendChild(msgDiv);
        container.scrollTop = container.scrollHeight;
    };

    window.sendUserChat = function() {
        const input = document.getElementById('userMessageInput');
        const content = input.value.trim();
        if (content && currentAdminId && currentPropertyId) {
            wsManager.sendMessage(currentAdminId, currentPropertyId, content);
            input.value = '';
        }
    };
</script>
</body>
</html>
