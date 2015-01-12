function s = AddSignal(s1, s2)

if length(s1) < length(s2)
    s = s2 + [s1 zeros(1,length(s2)-length(s1))];
else
    s = s1 + [s2 zeros(1,length(s1)-length(s2))];
end

end