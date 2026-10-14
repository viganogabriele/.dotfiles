-- Personal window geometry from the pre-Ruixen dotfiles configuration.
-- Load after desktop profiles so updates preserve mouse resizing and spacing.
hl.config({
  general = {
    gaps_in = 2,
    gaps_out = 4,
    resize_on_border = true,
  },
  decoration = {
    rounding = 10,
    rounding_power = 2,
  },
})
