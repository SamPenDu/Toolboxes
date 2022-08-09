function y = triwave(x)
% Returns the triangle wave of x based on sind(x)

Cs = cumsum(square((x*2)/180*pi));
y = sign(sind(x)) .* Cs / max(Cs);

