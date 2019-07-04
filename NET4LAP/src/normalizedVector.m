function vnorm = normalizedVector(v)
    maxValue = max(v);
    vnorm = v./maxValue;
end