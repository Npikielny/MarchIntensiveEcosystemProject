uniform float threshold;
_geometry.color = vec4(0.0,0.5,0.5,1.0);
if (threshold < _geometry.position.y) {
    _geometry.position.y = threshold;
    if (_geometry.position.y <= 0-2.8)
    _geometry.position.x = 0;
    _geometry.position.z = 0;
}
