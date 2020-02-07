uniform float x;
uniform float z;

if (_geometry.position.y <= 1.6) {
    _geometry.color = vec4(0.31,0.204,0.039,1.0);
}else {
    _geometry.color = vec4(0.315,1.0,0.017,1.0);
}

if ((_geometry.position.x-x)*(_geometry.position.x-x)+(_geometry.position.z-z)*(_geometry.position.z-z)<=10*10) {
    if ((_geometry.position.x-x)*(_geometry.position.x-x)+(_geometry.position.z-z)*(_geometry.position.z-z)>5*5) {
        _geometry.color = vec4(1.0,1.0,0.0,1.0);
    }
}
