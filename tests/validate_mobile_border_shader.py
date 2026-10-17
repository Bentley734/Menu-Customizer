"""Validate a captured LOVE border shader with the strict ESSL 1.00 compiler.
Capture the actual graphics.newShader argument containing borderRepeat.
Usage: python validate_mobile_border_shader.py path/to/glslang.exe captured.glsl
"""
from pathlib import Path
import subprocess,sys,tempfile
compiler,source=sys.argv[1:]
code=Path(source).read_text(encoding='utf-8')
assert 'float borderRepeat(vec3 path,float pitch)' in code
prefix='#version 100\nprecision highp float;\nprecision highp int;\n#define extern uniform\n#define Image sampler2D\n#define Texel texture2D\n'
suffix='\nuniform sampler2D MainTex;void main(){gl_FragColor=effect(vec4(1.0),MainTex,vec2(0.5),vec2(0.0));}\n'
with tempfile.TemporaryDirectory() as folder:
 shader=Path(folder)/'border.frag';shader.write_text(prefix+code+suffix,encoding='utf-8')
 result=subprocess.run([compiler,'-S','frag',str(shader)],capture_output=True,text=True)
 assert result.returncode==0,result.stdout+result.stderr
print('PASS strict ESSL100 border shader compilation')
