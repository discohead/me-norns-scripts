local matrix = {}

function matrix:note(midi_note, duration, f0_note)
    if type(midi_note) == 'table' then
        midi_note, duration, f0_note = table.unpack(midi_note)
    end
    midi_note, duration, f0_note = midi_note or 21, duration or 0.0625, f0_note or 21
    er301.note(1, midi_note, duration, f0_note)
end

function matrix:F_fine(volts)
    er301.cv(49, volts)
end

function matrix:E_fine(volts)
    er301.cv(40, volts)
end

function matrix:D_fine(volts)
    er301.cv(31, volts)
end

function matrix:C_fine(volts)
    er301.cv(22, volts)
end

function matrix:C_to_E(volts)
    er301.cv(27, volts)
end

function matrix:A_fine(volts)
    er301.cv(4, volts)
end

function matrix:E_to_E(volts)
    er301.cv(45, volts)
end

function matrix:F_to_E(volts)
    er301.cv(54, volts)
end

function matrix:A_to_A(volts)
    er301.cv(5, volts)
end

function matrix:B_to_A(volts)
    er301.cv(14, volts)
end

function matrix:C_to_A(volts)
    er301.cv(23, volts)
end

function matrix:D_to_A(volts)
    er301.cv(32, volts)
end

function matrix:F_track(volts)
    er301.cv(7, volts)
end

function matrix:F_to_A(volts)
    er301.cv(50, volts)
end

function matrix:D_to_E(volts)
    er301.cv(36, volts)
end

function matrix:D_to_B(volts)
    er301.cv(33, volts)
end

function matrix:C_to_C(volts)
    er301.cv(25, volts)
end

function matrix:name(volts)
    er301.cv(matrix, volts)
end

function matrix:B_fine(volts)
    er301.cv(13, volts)
end

function matrix:E_to_F(volts)
    er301.cv(46, volts)
end

function matrix:D_to_F(volts)
    er301.cv(37, volts)
end

function matrix:C_to_F(volts)
    er301.cv(28, volts)
end

function matrix:B_to_F(volts)
    er301.cv(19, volts)
end

function matrix:A_to_F(volts)
    er301.cv(10, volts)
end

function matrix:A_to_E(volts)
    er301.cv(9, volts)
end

function matrix:B_to_E(volts)
    er301.cv(18, volts)
end

function matrix:D_to_D(volts)
    er301.cv(35, volts)
end

function matrix:C_to_B(volts)
    er301.cv(24, volts)
end

function matrix:D_track(volts)
    er301.cv(5, volts)
end

function matrix:D_to_C(volts)
    er301.cv(34, volts)
end

function matrix:D_ratio(denominator)
    er301.cv(30, (denominator/24)*10)
end

function matrix:F_out(volts)
    er301.cv(47, volts)
end

function matrix:F_ratio(denominator)
    er301.cv(48, (denominator/24)*10)
end

function matrix:A_to_D(volts)
    er301.cv(8, volts)
end

function matrix:E_out(volts)
    er301.cv(38, volts)
end

function matrix:C_to_D(volts)
    er301.cv(26, volts)
end

function matrix:B_to_D(volts)
    er301.cv(17, volts)
end

function matrix:E_to_D(volts)
    er301.cv(44, volts)
end

function matrix:E_to_B(volts)
    er301.cv(42, volts)
end

function matrix:B_to_B(volts)
    er301.cv(15, volts)
end

function matrix:F_to_D(volts)
    er301.cv(53, volts)
end

function matrix:F_to_F(volts)
    er301.cv(55, volts)
end

function matrix:B_out(volts)
    er301.cv(11, volts)
end

function matrix:F_to_B(volts)
    er301.cv(51, volts)
end

function matrix:D_out(volts)
    er301.cv(29, volts)
end

function matrix:A_track(volts)
    er301.cv(2, volts)
end

function matrix:B_track(volts)
    er301.cv(3, volts)
end

function matrix:C_track(volts)
    er301.cv(4, volts)
end

function matrix:B_to_C(volts)
    er301.cv(16, volts)
end

function matrix:E_to_A(volts)
    er301.cv(41, volts)
end

function matrix:A_to_B(volts)
    er301.cv(6, volts)
end

function matrix:E_ratio(denominator)
    er301.cv(39, (denominator/24)*10)
end

function matrix:F_to_C(volts)
    er301.cv(52, volts)
end

function matrix:E_to_C(volts)
    er301.cv(43, volts)
end

function matrix:C_out(volts)
    er301.cv(20, volts)
end

function matrix:A_out(volts, x)
    er301.cv(2, volts)
end

function matrix:E_track(volts)
    er301.cv(6, volts)
end

function matrix:A_to_C(volts)
    er301.cv(7, volts)
end

function matrix:A_ratio(denominator)
    er301.cv(3, (denominator/24)*10)
end

function matrix:B_ratio(denominator)
    er301.cv(12, (denominator/24)*10)
end

function matrix:C_ratio(denominator)
    er301.cv(21, (denominator/24)*10)
end

return matrix