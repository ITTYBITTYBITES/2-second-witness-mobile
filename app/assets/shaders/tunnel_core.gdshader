shader_type canvas_item;

// Authoritative Wormhole Engine v2.0 - GOLD STANDARD
// Generates 100% dynamic perspective rings, volumetric fog, and spiral dust.

uniform vec4 color_primary : source_color = vec4(0.04, 0.07, 0.12, 1.0);
uniform vec4 color_secondary : source_color = vec4(0.07, 0.25, 0.44, 1.0);
uniform vec4 color_tertiary : source_color = vec4(0.17, 0.45, 0.7, 1.0);

uniform float flow_speed = 1.0;
uniform float density = 0.6;
uniform int flow_type = 0;
uniform sampler2D noise_tex : repeat_enable, filter_linear_mipmap;

void fragment() {
    vec2 uv = UV;
    vec2 center_uv = uv - 0.5;
    float dist = length(center_uv);
    float time = TIME * flow_speed;
    
    // 1. DYNAMIC PERSPECTIVE RINGS (y=-1 layer)
    // Using a logarithmic distance transform to create perspective
    float log_dist = log(dist + 0.01);
    float rings = sin(log_dist * 15.0 - time * 8.0);
    rings = smoothstep(0.8, 1.0, rings);
    rings *= smoothstep(0.5, 0.1, dist); // Fade center and edges
    
    // 2. VOLUMETRIC FOG / DEPTH
    float fog = pow(dist * 1.5, 2.0);
    vec3 base_col = mix(color_primary.rgb, color_secondary.rgb, clamp(fog, 0.0, 1.0));
    
    // 3. INWARD-SPIRALING PARTICLE DUST
    float angle = atan(center_uv.y, center_uv.x);
    // Transform UV to spiraling polar coordinates
    vec2 polar_uv = vec2(log_dist - time * 0.4, (angle / (2.0 * PI)) + log_dist * 0.5);
    float dust = texture(noise_tex, polar_uv * 3.0).r;
    dust = pow(dust, 4.0) * 5.0; // High contrast specks
    
    // 4. COMPOSITING
    vec3 final_rgb = base_col;
    
    // Add rings with Tertiary Glow
    final_rgb += color_tertiary.rgb * rings * 0.4;
    
    // Add spiraling dust with Tertiary Highlights
    final_rgb += color_tertiary.rgb * dust * 0.2;
    
    // Apply Vignette for focus
    float vignette = smoothstep(0.8, 0.2, dist);
    final_rgb *= vignette;
    
    // Bloom approximation for rings/dust
    final_rgb += color_tertiary.rgb * rings * rings * 0.2;

    COLOR = vec4(final_rgb, 1.0);
}
