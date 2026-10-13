shader_type canvas_item;
// Fundo psicodélico leve: ondas de cor que mudam devagar (sem texturas, barato).

uniform vec4 color_a : source_color = vec4(0.09, 0.05, 0.2, 1.0);
uniform vec4 color_b : source_color = vec4(0.18, 0.1, 0.36, 1.0);
uniform vec4 color_c : source_color = vec4(0.42, 0.14, 0.5, 1.0);
uniform vec2 world_size = vec2(1280.0, 720.0);
uniform float pattern_scale = 0.004;
uniform float speed = 0.25;

void fragment() {
	vec2 p = UV * world_size * pattern_scale;
	float t = TIME * speed;
	float v = sin(p.x * 3.0 + t * 2.0)
		+ sin(p.y * 3.7 - t * 1.6)
		+ sin((p.x + p.y) * 2.1 + t)
		+ sin(length(p - vec2(4.0, 3.0)) * 4.0 - t * 3.0);
	v = v * 0.125 + 0.5;
	vec3 col = mix(color_a.rgb, color_b.rgb, smoothstep(0.25, 0.75, v));
	col = mix(col, color_c.rgb, smoothstep(0.7, 1.0, v) * 0.7);
	COLOR = vec4(col, 1.0);
}
