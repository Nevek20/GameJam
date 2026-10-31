shader_type canvas_item;
// Chão de grama: cor mais forte (saturação/brilho) e manchas onduladas claras/escuras, paradas,
// para quebrar a repetição da textura. Ajuste no Inspector: Level -> Ground -> Material.

uniform float saturation = 1.25;
uniform float brightness = 0.85;
// Força das ondas (0 = sem ondas).
uniform float wave_strength = 0.14;
// Tamanho das ondas: menor = ondas maiores.
uniform float wave_scale = 0.004;

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec4 c = COLOR;
	float gray = dot(c.rgb, vec3(0.299, 0.587, 0.114));
	c.rgb = mix(vec3(gray), c.rgb, saturation) * brightness;
	vec2 p = world_pos * wave_scale;
	float w = sin(p.x + sin(p.y * 0.7) * 2.0) * 0.5 + sin(p.y * 1.3 + sin(p.x * 0.6) * 1.7) * 0.5;
	c.rgb *= 1.0 + w * wave_strength;
	COLOR = c;
}
