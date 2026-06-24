shader_type canvas_item;

// Theme Manager Injected Colors
uniform vec4 color_primary : source_color = vec4(0.04, 0.07, 0.12, 1.0);
uniform vec4 color_secondary : source_color = vec4(0.07, 0.25, 0.44, 1.0);
uniform vec4 color_tertiary : source_color = vec4(0.17, 0.45, 0.7, 1.0);

// Dynamics
uniform float flow_speed = 1.0;
uniform float density = 0.6;
uniform int flow_type = 0; // Uniform branching is essentially free on mobile GPUs

// PRODUCTION OPTIMIZATION: Replacing heavy procedural math with texture lookups
// This removes hundreds of ALU instructions per pixel.
uniform sampler2D noise_tex : repeat_enable, filter_linear_mipmap;

void fragment() {
    vec2 uv = UV;
    float time = TIME * flow_speed * 0.5;
    vec2 flow_uv = uv;

    // Uniform branching executes identically across the warp, preventing divergence
    if (flow_type == 0) { // Linear Stream
        flow_uv.y -= time;
    } 
    else if (flow_type == 1) { // Vortex
        vec2 center = uv - 0.5;
        float angle = atan(center.y, center.x) + time;
        float radius = length(center) - (time * 0.1);
        flow_uv = vec2(cos(angle), sin(angle)) * radius;
    } 
    else if (flow_type == 2) { // Branching
        // Using texture lookup instead of procedural sin/fract noise
        flow_uv.x += texture(noise_tex, uv * 0.5 + time * 0.1).r * 0.2;
        flow_uv.y -= time * 1.5;
    }
    else if (flow_type == 3) { // Wave
        flow_uv.x += sin(uv.y * 10.0 * density + time) * 0.1;
        flow_uv.y -= time;
    }

    // Single-pass depth mapping using precomputed noise texture lookups
    float n1 = texture(noise_tex, flow_uv * density).r;
    float n2 = texture(noise_tex, flow_uv * density * 2.0 - vec2(time * 0.2)).r;

    // Optimized Linear Interpolation
    vec4 col = mix(color_primary, color_secondary, n1);
    col = mix(col, color_tertiary, n2);
    
    // Cheap vignette without length() cost
    float dist = distance(uv, vec2(0.5));
    col.rgb *= smoothstep(0.9, 0.1, dist);

    COLOR = col;
}