vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords) {
    vec4 pixel = Texel(texture, textureCoords) * color;
    pixel.r = 1.0;
    pixel.g = 1.0;
    pixel.b = 1.0;
    return pixel;
}