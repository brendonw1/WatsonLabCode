%
% Minor colorbar improvements. Custom colorbar position preserves
% subplot position, unlike default values such as 'eastoutside'.
% 
% Bueno-Junior et al. (2023)

%%
ax = gca;
c  = colorbar;
c.Position(1) = sum(ax.Position([1 3]))+c.Position(3);
c.FontSize = 12;
c.Label.FontSize = 14;