#!/usr/bin/env bash
# Deploy the Transform Group site from the ~/Downloads working copy to this repo
# with clean (extensionless) URLs, then push. Usage: ./deploy.sh "commit message"
set -e
MSG="${1:-Update site}"
SRC=/Users/hannahrojenne/Downloads
REPO=/Users/hannahrojenne/transform-group-website
BASE="https://www.transformgroup.com"

cp "$SRC/transform-group-website.html" "$REPO/index.html"
for f in team division-pr division-strategies division-events socialradius; do cp "$SRC/$f.html" "$REPO/"; done
cp "$SRC/site.css" "$SRC/robots.txt" "$SRC/sitemap.xml" "$SRC/llms.txt" "$REPO/"
for f in og-cover og-team og-pr og-strategies og-events og-socialradius; do cp "$SRC/$f.png" "$REPO/" 2>/dev/null || true; done
mkdir -p "$REPO/img"
for f in logo.png logo-3d.png michael-terpin.jpg xenia-von-wedel.jpg lynessa-martin.jpg joyce-chow.jpg; do cp "$SRC/img/$f" "$REPO/img/" 2>/dev/null || true; done
echo "www.transformgroup.com" > "$REPO/CNAME"

cd "$REPO"
python3 - "$BASE" << 'PY'
import sys, glob
BASE=sys.argv[1]
names=['team','division-pr','division-strategies','division-events','socialradius']
slug={'/transform-pr':'/division-pr','/transform-strategies':'/division-strategies','/transform-events':'/division-events'}
for f in glob.glob('*.html'):
    if f.startswith('google'): continue
    s=open(f,encoding='utf-8').read()
    s=s.replace('transform-group-website.html','/')
    for a,b in slug.items(): s=s.replace(BASE+a, BASE+b)
    s=s.replace(BASE+'/logo.png', BASE+'/img/logo.png')
    for n in names: s=s.replace(n+'.html', n)
    s=s.replace('index.html','/')
    open(f,'w',encoding='utf-8').write(s)
for f in ['sitemap.xml','llms.txt']:
    s=open(f,encoding='utf-8').read()
    for n in names: s=s.replace(n+'.html', n)
    open(f,'w',encoding='utf-8').write(s)
PY
git add -A
if git diff --cached --quiet; then echo "no changes to deploy"; else git commit -q -m "$MSG" && git push -q origin main && echo "deployed: $MSG"; fi
