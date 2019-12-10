uniform float threshold;
if (threshold > _geometry.position.y) {
    _geometry.color = vec4(0.0,0.0,0.0,1.0);
}else {
    _geometry.color = vec4(1.0,0.0,0.966,1.0);
}
