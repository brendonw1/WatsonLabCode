function cv = coeffvar(data)

good = ~isnan(data);
cv = mean(data(good))/var(data(good));
