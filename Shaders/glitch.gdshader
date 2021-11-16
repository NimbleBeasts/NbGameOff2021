/*
	Glitch Effect Shader by Yui Kinomoto @arlez80
	Vignet and more by: https://github.com/hiulit/Godot-3-2D-CRT-Shader
	Modified for GameOff2021 Jam
*/

shader_type canvas_item;




uniform bool noise_enabled = true;
uniform bool glitch_enabled = false;

uniform float shake_power = 0.03;
uniform float shake_rate : hint_range( 0.0, 1.0 ) = 0.2;
uniform float shake_speed = 5.0;
uniform float shake_block_size = 30.5;
uniform float shake_color_rate : hint_range( 0.0, 1.0 ) = 0.01;

uniform float vignette_opacity : hint_range(0.1, 0.5, 0.01) = float(0.15);
uniform vec2 screen_size = vec2(320.0, 180.0);


uniform float aberration_amount : hint_range(0.0, 10.0, 0.1) = float(0.1);
uniform bool move_aberration = false;
uniform float aberration_speed : hint_range(0.01, 10.0, 0.01) = float(4.01);

uniform float white_noise_rate : hint_range( 0.0, 1.0 ) = 0.0;

void draw_vignette(inout vec3 color, vec2 uv) {
	float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
	vignette = clamp(pow((screen_size.x / 4.0) * vignette, vignette_opacity), 0.0, 1.0);
	color *= vignette;
}

float random_vec2( vec2 pos )
{ 
	return fract(sin(dot(pos, vec2(12.9898,78.233))) * 43758.5453);
}

float random( float seed )
{
	return fract( 543.2543 * sin( dot( vec2( seed, seed ), vec2( 3525.46, -54.3415 ) ) ) );
}

void fragment( )
{	
	vec2 aperture_grille_pixel = vec2( floor( ( SCREEN_UV.x / SCREEN_PIXEL_SIZE.x ) / 3.0 ) * 3.0, SCREEN_UV.y );
	float white_noise = random_vec2( aperture_grille_pixel + vec2( sin( TIME * 0.343254 ), cos( TIME * 0.254323563 ) ) );
	float enable_color = float( 0.0 <= UV.x && UV.x <= 1.0 && 0.0 <= UV.y && UV.y <= 1.0 );
	
	if (glitch_enabled) {
		float enable_shift = float(
			random( ( TIME * shake_speed ) )
		<	shake_rate
		);

		vec2 fixed_uv = SCREEN_UV;
		fixed_uv.x += (
			random(
				( trunc( SCREEN_UV.y * shake_block_size ) / shake_block_size )
			+	TIME
			) - 0.5
		) * shake_power * enable_shift;

		vec3 color = texture( SCREEN_TEXTURE, fixed_uv ).rgb;
		
		if (aberration_amount > 0.0) {
			float adjusted_amount = aberration_amount / screen_size.x;
			
			if (move_aberration == true) {
				adjusted_amount = (aberration_amount / screen_size.x) * cos((2.0 * 3.14159265359) * (TIME / aberration_speed));
			} 
			
			color.r = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x + adjusted_amount, SCREEN_UV.y)).r;
			color.g = texture(SCREEN_TEXTURE, SCREEN_UV).g;
			color.b = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x - adjusted_amount, SCREEN_UV.y)).b;
		}
		
		color.r = mix(
			color.r
		,	texture( SCREEN_TEXTURE, fixed_uv + vec2( shake_color_rate, 0.0 ) ).r
		,	enable_shift
		);
		color.b = mix(
			color.b
		,	texture( SCREEN_TEXTURE, fixed_uv + vec2( -shake_color_rate, 0.0 ) ).b
		,	enable_shift
		);
		draw_vignette(color, UV);
		
		if (noise_enabled) {
			COLOR.rgb = mix(
				color.rgb
			,	vec3( white_noise, white_noise, white_noise )
			,	white_noise_rate * enable_color
			);
		} else {
			COLOR.rgb = color.rgb;
		}
	} else {
	
	
	
	
	vec3 color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	if (aberration_amount > 0.0) {
		float adjusted_amount = aberration_amount / screen_size.x;
		
		if (move_aberration == true) {
			adjusted_amount = (aberration_amount / screen_size.x) * cos((2.0 * 3.14159265359) * (TIME / aberration_speed));
		} 
		
		color.r = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x + adjusted_amount, SCREEN_UV.y)).r;
		color.g = texture(SCREEN_TEXTURE, SCREEN_UV).g;
		color.b = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x - adjusted_amount, SCREEN_UV.y)).b;
	}
	if (UV.x < 0.0 || UV.x > 1.0 || UV.y < 0.0 || UV.y > 1.0) {
		color = vec3(0.0, 0.0, 0.0);
	}
	

	
	draw_vignette(color, UV);
	
	if (noise_enabled) {
		COLOR.rgb = mix(
			color.rgb
		,	vec3( white_noise, white_noise, white_noise )
		,	white_noise_rate * enable_color
		);
	} else {
		COLOR.rgb = color.rgb;
	}
	
	//COLOR = vec4(color, 1.0);
	
	
		//COLOR = texture( SCREEN_TEXTURE, SCREEN_UV );
	}
}
