enum ParamId {
  id,
  vgs,
  vth,
  vov,
  gm,
  gmId,
  wl,
  uCox,
  ro,
  lambda,
  av0,
  cgs,
  ft,
}

class ParamMeta {
  const ParamMeta({
    required this.name,
    required this.symbol,
    required this.unit,
    required this.toSiFactor,
  });

  final String name;
  final String symbol;
  final String unit;
  final double toSiFactor;
}

const Map<ParamId, ParamMeta> kParamMeta = {
  ParamId.id: ParamMeta(
    name: 'Drain Current',
    symbol: 'I_D',
    unit: 'uA',
    toSiFactor: 1e-6,
  ),
  ParamId.vgs: ParamMeta(
    name: 'Gate-Source Voltage',
    symbol: 'V_GS',
    unit: 'mV',
    toSiFactor: 1e-3,
  ),
  ParamId.vth: ParamMeta(
    name: 'Threshold Voltage',
    symbol: 'V_TH',
    unit: 'mV',
    toSiFactor: 1e-3,
  ),
  ParamId.vov: ParamMeta(
    name: 'Overdrive Voltage',
    symbol: 'V_OV',
    unit: 'mV',
    toSiFactor: 1e-3,
  ),
  ParamId.gm: ParamMeta(
    name: 'Transconductance',
    symbol: 'g_m',
    unit: 'mA/V',
    toSiFactor: 1e-3,
  ),
  ParamId.gmId: ParamMeta(
    name: 'Efficiency Ratio',
    symbol: 'g_m/I_D',
    unit: '1/V',
    toSiFactor: 1.0,
  ),
  ParamId.wl: ParamMeta(
    name: 'Aspect Ratio',
    symbol: 'W/L',
    unit: '-',
    toSiFactor: 1.0,
  ),
  ParamId.uCox: ParamMeta(
    name: 'Process Transconductance',
    symbol: 'u_nC_ox',
    unit: 'uA/V^2',
    toSiFactor: 1e-6,
  ),
  ParamId.ro: ParamMeta(
    name: 'Output Resistance',
    symbol: 'r_o',
    unit: 'kOhm',
    toSiFactor: 1e3,
  ),
  ParamId.lambda: ParamMeta(
    name: 'Channel Length Modulation',
    symbol: 'lambda',
    unit: '1/V',
    toSiFactor: 1.0,
  ),
  ParamId.av0: ParamMeta(
    name: 'Intrinsic Gain',
    symbol: 'A_v0',
    unit: 'V/V',
    toSiFactor: 1.0,
  ),
  ParamId.cgs: ParamMeta(
    name: 'Gate-Source Capacitance',
    symbol: 'C_gs',
    unit: 'fF',
    toSiFactor: 1e-15,
  ),
  ParamId.ft: ParamMeta(
    name: 'Transit Frequency',
    symbol: 'f_T',
    unit: 'GHz',
    toSiFactor: 1e9,
  ),
};

extension ParamIdX on ParamId {
  ParamMeta get meta => kParamMeta[this]!;
}
