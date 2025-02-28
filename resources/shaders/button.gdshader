shader_type canvas_item;

uniform vec4 target_color : source_color; // Couleur de remplacement

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Détecte si le pixel est noir (ou proche)
    float intensity = dot(tex_color.rgb, vec3(0.333)); // Luminosité moyenne
    if (intensity < 0.2) {
        // Remplace la couleur tout en conservant l'alpha
        COLOR = vec4(target_color.rgb, tex_color.a);
    } else {
        // Garde les autres pixels intacts
        COLOR = tex_color;
    }
}
