uniform float threshold;
_geometry.color = vec4(1.0,0.0,0.966,1.0);
if (threshold < _geometry.position.y) {
    _geometry.position.y = threshold;
}
