shader_type canvas_item;

uniform bool ghost_enabled = false;

uniform float beam_progress : hint_range(0.0, 1.0);
uniform float beam_noise_density = 60;
uniform float beam_size : hint_range(0.01, 0.15);
uniform vec4 beam_color : hint_color = vec4(0.0, 1.02, 1.2, 1.0);


vec2 random(vec2 uv) {
	uv = vec2( dot(uv, vec2(127.1,311.7) ), dot(uv, vec2(269.5,183.3) ) );
	return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
	vec2 uv_index = floor(uv);
	vec2 uv_fract = fract(uv);

	vec2 blur = smoothstep(0.0, 1.0, uv_fract);

	return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
					dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
				mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
					dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) * 0.5 + 0.5;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	float noise = noise(UV * beam_noise_density) * UV.y;

	float d1 = step(beam_progress, noise);
	float d2 = step(beam_progress - beam_size, noise);

	vec3 beam = vec3(d2 - d1) * beam_color.rgb;
	
	
	tex.rgb += beam;
	tex.a *= d2;


	if (ghost_enabled) {
	    float avg = (tex.r + tex.g  + tex.b ) / 3.0;
	    COLOR.rgba = vec4(tex.r * 0.1 + avg * 0.4, tex.g * 0.1 + avg * 0.4, tex.b * 0.3 + avg * 0.7, tex.a);
	} else {
		COLOR = tex
	}
}