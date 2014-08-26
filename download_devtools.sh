svn export https://src.chromium.org/blink/trunk/Source/devtools --trust-server-cert --non-interactive
cd devtools
./scripts/CodeGeneratorFrontend.py protocol.json --output_js_dir front_end
svn export https://src.chromium.org/blink/trunk/Source/core/css/CSSProperties.in --trust-server-cert --non-interactive
./scripts/generate_supported_css.py CSSProperties.in front_end/SupportedCSSProperties.js

