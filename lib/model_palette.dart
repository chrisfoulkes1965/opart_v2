import 'dart:math';

import 'package:flutter/material.dart';

import 'package:opart_v2/app_state.dart';
import 'package:opart_v2/model_settings.dart';

SettingsModel numberOfColors = SettingsModel(
  name: 'numberOfColors',
  settingType: SettingType.int,
  label: 'Number of Colors',
  tooltip: 'The number of colours in the palette',
  min: 1,
  max: 36,
  defaultValue: 10,
  icon: const Icon(Icons.palette),
  settingCategory: SettingCategory.palette,
  proFeature: false,
  onChange: () {
    checkNumberOfColors();
  },
);
SettingsModel lineColor = SettingsModel(
  name: 'lineColor',
  settingType: SettingType.color,
  label: 'Outline Color',
  tooltip: 'The outline colour for the petals',
  defaultValue: Colors.white,
  icon: const Icon(Icons.zoom_out_map),
  settingCategory: SettingCategory.palette,
  proFeature: false,
);
SettingsModel opacity = SettingsModel(
  name: 'opacity',
  settingType: SettingType.double,
  label: 'Opactity',
  tooltip: 'The opacity of the petal',
  min: 0.2,
  max: 1.0,
  zoom: 100,
  defaultValue: 1.0,
  icon: const Icon(Icons.remove_red_eye),
  settingCategory: SettingCategory.palette,
  proFeature: false,
);
SettingsModel backgroundColor = SettingsModel(
  name: 'backgroundColor',
  settingType: SettingType.color,
  label: 'Background Color',
  tooltip: 'The background colour for the canvas',
  defaultValue: Colors.cyan,
  icon: const Icon(Icons.settings_overscan),
  settingCategory: SettingCategory.palette,
  proFeature: false,
);

SettingsModel randomColors = SettingsModel(
  name: 'randomColors',
  settingType: SettingType.bool,
  label: 'Random Colors',
  tooltip: 'randomize the colours!',
  defaultValue: false,
  icon: const Icon(Icons.gamepad),
  settingCategory: SettingCategory.tool,
  proFeature: false,
  silent: true,
  // onChange:(){randomColors.value = !randomColors.value;}
);

SettingsModel paletteType = SettingsModel(
  settingType: SettingType.list,
  name: 'paletteType',
  label: 'Palette Type',
  tooltip: 'The nature of the palette',
  defaultValue: 'random',
  icon: const Icon(Icons.colorize),
  options: <String>[
    'random',
    'blended random',
    'linear random',
    'linear complementary'
  ],
  settingCategory: SettingCategory.palette,
  onChange: () {
    generatePalette();
  },
  proFeature: false,
);
SettingsModel paletteList = SettingsModel(
  name: 'paletteList',
  settingType: SettingType.list,
  label: 'Palette',
  tooltip: 'Choose from a list of palettes',
  defaultValue: 'Default',
  icon: const Icon(Icons.palette),
  options: defaultPalleteNames(),
  settingCategory: SettingCategory.other,
  proFeature: false,
);

List<String> defaultPalleteNames() {
  return [
    'Default',
    'Black and White',
    'Doge Leonardo',
    'The Birth of Venus',
    'Bridget Riley - Achæan',
    'Bridget Riley - Evoe 3',
    'Bridget Riley - Fete',
    'Bridget Riley - Nataraja',
    'Bridget Riley - Summers Day',
    'Da Vinci - The Last Supper',
    'Da Vinci - The Mona Lisa',
    'Gaugin - Woman of the Mango',
    'Gericault - Raft of the Medusa',
    'Grant Wood - American Gothic',
    'Hockney - Felled Trees on Woldgate',
    'Hockney - Pacific Coast Highway',
    'Hockney - The Arrival of Spring',
    'Hopper - Nighthawks',
    'Hokusai - The Great Wave',
    'Klimt - The Kiss',
    'Matisse - Danse',
    'Matisse - Danse I',
    'Matisse - Icarus',
    'Matisse - Jazz',
    'Matisse - La Gerbe',
    'Matisse - Les Codomas',
    'Matisse - Snow Flowers',
    'Matisse - Parakeet and the Mermaid',
    'Matisse - The Snail',
    'Mondrian',
    'Monet - Charing Cross Bridge',
    'Munch - The Scream',
    'Picasso - Guernica',
    'Picasso - The Tragedy',
    'Picasso - The Tragedy - reduced',
    'Seurat - Sunday Afternoon',
    'Van Eyck - The Arnolfini Portrait',
    'Van Gogh - Self Portrait',
    'Van Gogh - The Starry Night',
    'Van Gogh - Wheat Field with Cypresses',
    'Vermeer - Girl with a Pearl Earring',
    'Whistlers Mother',
    'Goat 1',
    'Goat 2',
    'Goat 3',
    'Maits Stairs',
    'Lilly',
    'Man in blue hat',
    'Spider',
    'Deck Chairs',
    'Bo Kaap',
    'Pantone Pop Stripes',
    'Purple Artichokes',
    'Stained Glass',
    'Ferns',
    'Rhubarb',
    'SriDevi',
    'Peacock',
    'Coronavirus',
  ];
}

List<List> defaultPalettes = [
  [
    'Default',
    10,
    '0xFF00BCD4',
    [
      '0xFF37A7BC',
      '0xFFB4B165',
      '0xFFA47EA4',
      '0xFF69ABCB',
      '0xFF79B38E',
      '0xFF17B8E0',
      '0xFFD1EFED',
      '0xFF151E2A',
      '0xFF725549',
      '0xFF074E71'
    ]
  ],
  [
    'Classic',
    10,
    '0xFFffffff',
    [
      '0xFF34a1af',
      '0xFFa570a8',
      '0xFFd6aa27',
      '0xFF5f9d50',
      '0xFF789dd1',
      '0xFFc25666',
      '0xFF2b7b1',
      '0xFFd63aa',
      '0xFF1f4ed',
      '0xFF383c47'
    ]
  ],
  [
    'Black and White',
    2,
    '0xFF111111',
    ['0xFF000000', '0xFFffffff']
  ],
  [
    'Rainbow',
    6,
    '0xFF000000',
    [
      '0xFFF44336',
      '0xFFFF9800',
      '0xFFFFEB3B',
      '0xFF4CAF50',
      '0xFF2196F3',
      '0xFF9C27B0'
    ],
  ],
  //  ['Doge Leonardo',10,'0xFFffffff',['0xFF335362','0xFF30444C','0xFF324B56','0xFF5C381E','0xFF403424','0xFF605239','0xFF7B6A4C','0xFF9A8564','0xFFB3A889','0xFF273638']],
  // ['The Birth of Venus',10,'0xFFffffff',['0xFF303227','0xFF13160F','0xFF514F3D','0xFF7AA58B','0xFF647A63','0xFF9C8E64','0xFFA9C9AB','0xFFC0B381','0xFF8C6240','0xFFE3E0B0']],
  // ['Bridget Riley - Achæan',10,'0xFFffffff',['0xFF37A7BC','0xFFB4B165','0xFFA47EA4','0xFF69ABCB','0xFF79B38E','0xFF17B8E0','0xFFD1EFED','0xFF151E2A','0xFF725549','0xFF074E71']],
  // ['Bridget Riley - Evoe 3',3,'0xFFffffff',['0xFFBDABB3','0xFF4A6FBA','0xFF468889']],
//  ['Bridget Riley - Fete',10,'0xFFffffff',['0xFF45719C','0xFFC3605A','0xFF78A8D0','0xFF2C2F34','0xFFE8EAE3','0xFF6A9056','0xFFAC88AA','0xFFCFC177','0xFF72AD9A','0xFF856974']],
  [
    'Bridget Riley',
    10,
    '0xFFffffff',
    [
      '0xFFB7594C',
      '0xFF7795C5',
      '0xFFD2A648',
      '0xFF3D679D',
      '0xFFE3CE9C',
      '0xFFB783A1',
      '0xFF366A52',
      '0xFF92B159',
      '0xFF66874C',
      '0xFF61A578'
    ]
  ],
  // ['Bridget Riley - Summers Day',10,'0xFFffffff',['0xFFF2EEF2','0xFFF3EAE0','0xFFC3AE7F','0xFFA5B0CD','0xFFB5AF97','0xFFACAEB7','0xFFCAAC96','0xFFC4ADAD','0xFFDECFBE','0xFFD0D2E1']],
  [
    'Last Supper',
    10,
    '0xFFffffff',
    [
      '0xFF68533B',
      '0xFF826347',
      '0xFF3F2F1A',
      '0xFF52412C',
      '0xFF94755C',
      '0xFF656462',
      '0xFF251A0B',
      '0xFF787C7F',
      '0xFFA08F80',
      '0xFFB5ADA5'
    ]
  ],
  [
    'Mona Lisa',
    10,
    '0xFFffffff',
    [
      '0xFF1B0C06',
      '0xFF35240E',
      '0xFF4F3916',
      '0xFFA28832',
      '0xFF887329',
      '0xFFBE9F3D',
      '0xFFEAB439',
      '0xFF675D25',
      '0xFF814811',
      '0xFFBD751B'
    ]
  ],
  //['Gaugin - Woman of the Mango',10,'0xFFffffff',['0xFF222843','0xFF313350','0xFF121C2E','0xFFBD8F03','0xFF403825','0xFF614020','0xFF606E70','0xFF88928B','0xFFA68319','0xFF8D501A']],
//  ['Gericault - Raft of the Medusa',10,'0xFFffffff',['0xFF46341A','0xFF21190E','0xFF342514','0xFF0D0D08','0xFF554525','0xFF695531','0xFF856A3E','0xFFA28250','0xFFBE9E63','0xFFE3C47F']],
//  ['Grant Wood - American Gothic',10,'0xFFffffff',['0xFF1A1F24','0xFFC5B088','0xFF7E7966','0xFF6A624C','0xFFC0DECD','0xFFA49477','0xFFD7CAA4','0xFF50462E','0xFFCAEAE1','0xFFECE9C5']],
  [
    'Hockney',
    10,
    '0xFFffffff',
    [
      '0xFF0D9155',
      '0xFF167691',
      '0xFF14341D',
      '0xFFB1D3E7',
      '0xFFB9A0AC',
      '0xFF604065',
      '0xFF52A3BC',
      '0xFFE5BD81',
      '0xFFA88451',
      '0xFF51B871'
    ]
  ],
  // ['Hockney - Pacific Coast Highway',10,'0xFFffffff',['0xFF1157A0','0xFFB04A12','0xFF0B5B24','0xFF5C6E9D','0xFF6D942B','0xFF272A36','0xFF7BACAD','0xFFA87BA2','0xFF22846E','0xFFCBBC09']],
  // ['Hockney - The Arrival of Spring',10,'0xFFffffff',['0xFF15987B','0xFF2A6A3B','0xFF852308','0xFF502F18','0xFF0F4318','0xFF98553F','0xFF805986','0xFF5B955E','0xFFCCBF56','0xFF0FBF16']],
  //['Hopper - Nighthawks',10,'0xFFffffff',['0xFF1C2521','0xFF1F3430','0xFF659170','0xFFDEDD86','0xFF3E5C48','0xFF342315','0xFF53311F','0xFF462212','0xFF70331B','0xFFAC772D']],
  [
    'Hokusai',
    6,
    '0xFFffffff',
    [
      '0xFFEBE5CC',
      '0xFFD6CDB2',
      '0xFFB7B5A2',
      '0xFF888B82',
      '0xFF4B5560',
      '0xFF243042'
    ]
  ],
  [
    'The Kiss',
    10,
    '0xFFffffff',
    [
      '0xFFBFA552',
      '0xFFD0B350',
      '0xFF786331',
      '0xFFB19543',
      '0xFFC0B393',
      '0xFF907839',
      '0xFF968E72',
      '0xFF66588F',
      '0xFFB85D3C',
      '0xFF413526'
    ]
  ],
  // ['Matisse - Danse',4,'0xFFffffff',['0xFF354762','0xFFB64237','0xFF27584C','0xFF6F2121']],
  //['Matisse - Danse I',5,'0xFFffffff',['0xFF495696','0xFFBE8A7E','0xFF4D6B68','0xFF334F49','0xFF2A2622']],
  //['Matisse - Icarus',4,'0xFFffffff',['0xFF2459E4','0xFF101626','0xFFE7E273','0xFF940F0A']],
  [
    'Matisse - Jazz',
    5,
    '0xFFffffff',
    ['0xFFE9E8D0', '0xFF07090A', '0xFFD92D2A', '0xFF1766F3', '0xFFE5F146']
  ],
  [
    'Matisse - La Gerbe',
    6,
    '0xFFffffff',
    [
      '0xFFEFEAD9',
      '0xFF266EA8',
      '0xFF255B37',
      '0xFF8DAA8A',
      '0xFFD7AA3F',
      '0xFFB9454E'
    ]
  ],
  //['Matisse - Les Codomas',8,'0xFFffffff',['0xFFCF881C','0xFFE6DF2D','0xFF1D1D14','0xFFD7DCD6','0xFF5A9C8A','0xFF97263F','0xFF264AC6','0xFFE2EBE9']],
  // ['Matisse - Snow Flowers',9,'0xFFffffff',['0xFFDC9E84','0xFFE2D7C5','0xFFD16886','0xFFE9E5DC','0xFF1E433E','0xFFCCCABF','0xFFA51612','0xFF527799']],
  // ['Matisse - Parakeet and the Mermaid',10,'0xFFffffff',['0xFFF4FAFC','0xFFD18707','0xFFA710AA','0xFF3A3408','0xFF0B8AB3','0xFF1DB314','0xFF1F152C','0xFF8D5A09','0xFF6A0F69','0xFF0C526D']],
  // ['Matisse - The Snail',8,'0xFFffffff',['0xFFFB7C1C','0xFF4AE95F','0xFFEADECB','0xFFC864E2','0xFF407CF5','0xFFE4A060','0xFFE2162A','0xFF131716']],
  [
    'Mondrian',
    6,
    '0xFFffffff',
    [
      '0xFFF50F0F',
      '0xFFF8E213',
      '0xFF0C7EBD',
      '0xFFF2F2F2',
      '0xFF000000',
      '0xFF363636'
    ]
  ],
  //['Monet - Charing Cross Bridge',10,'0xFFffffff',['0xFF929696','0xFF778D99','0xFF86918D','0xFF788B86','0xFF84969E','0xFF9CA19F','0xFF688796','0xFF9E9585','0xFF587D8A','0xFFB7AB9D']],
  //['Munch - The Scream',10,'0xFFffffff',['0xFF403130','0xFF644D3C','0xFFD6995C','0xFFCF5629','0xFF8D6D46','0xFFD57C42','0xFF21141B','0xFFAE8552','0xFF625E67','0xFFD18C2D']],
  //['Picasso - Guernica',10,'0xFFffffff',['0xFF33362D','0xFF292B22','0xFFDAD5CF','0xFFC5C0B8','0xFF1B1C14','0xFFAAA89F','0xFF595C51','0xFF8D8D82','0xFF45483D','0xFF6F7268']],
  [
    'Picasso - The Tragedy',
    10,
    '0xFFffffff',
    [
      '0xFF1E4056',
      '0xFF5398AC',
      '0xFF285873',
      '0xFF6DBFE6',
      '0xFF4CA4D7',
      '0xFF6FAEBA',
      '0xFF132833',
      '0xFF8FD4E8',
      '0xFF417C8F',
      '0xFF2D7CAD'
    ]
  ],
  // ['Picasso - The Tragedy - reduced',5,'0xFFffffff',['0xFF5AA5C3','0xFF3D81A0','0xFF7DC8E5','0xFF26536D','0xFF173140']],
  //['Seurat - Sunday Afternoon',10,'0xFFffffff',['0xFF343C33','0xFF495B42','0xFF64665F','0xFF4A4956','0xFFB4AE79','0xFF7E7E7D','0xFF9F9A69','0xFF817E56','0xFFA0A6A9','0xFFC8C6BA']],
  //['Van Eyck - The Arnolfini Portrait',10,'0xFFffffff',['0xFF292225','0xFF141517','0xFF393231','0xFF542527','0xFF20350B','0xFF634B3C','0xFF304E0A','0xFF726859','0xFF9C907A','0xFFC4BCAB']],
  [
    'Van Gogh',
    10,
    '0xFFffffff',
    [
      '0xFF7E9989',
      '0xFF93B2A4',
      '0xFF70897B',
      '0xFFA4C3B3',
      '0xFF999C6D',
      '0xFF7B7442',
      '0xFF556D65',
      '0xFFBFC092',
      '0xFF4F4F2D'
    ]
  ],
  //['Van Gogh - The Starry Night',10,'0xFFffffff',['0xFF44608A','0xFF191F1E','0xFF5A799D','0xFF283441','0xFF2C4175','0xFF8098A4','0xFF6E837F','0xFFA8B391','0xFF47585C','0xFFA79F39']],
  //['Van Gogh - Wheat Field with Cypresses',10,'0xFFffffff',['0xFF94A3A7','0xFFABB6B4','0xFF7E9196','0xFF8B791A','0xFF495936','0xFFC7CDC2','0xFF213421','0xFFAC9934','0xFF6C7B51','0xFF637982']],
  //['Vermeer - Girl with a Pearl Earring',10,'0xFFffffff',['0xFF181308','0xFF28261C','0xFF716046','0xFF9A8059','0xFF4A3E2C','0xFF2A3844','0xFFC0A687','0xFFDBC7B5','0xFF93A2AF','0xFF617586']],
  //['Whistlers Mother',10,'0xFFffffff',['0xFF111012','0xFF2E2D30','0xFF888985','0xFFFEFEFE','0xFF42403D','0xFF5E594B','0xFF767772','0xFFE7E7E8','0xFFB2AA9C','0xFFC9C6BF']],
  //['Goat 1',8,'0xFFffffff',['0xFF413734','0xFF282222','0xFF76665E','0xFF674A3E','0xFF4E4F50','0xFF8E8078','0xFFB0A59C','0xFFDFD7CD']],
  //['Goat 2',8,'0xFFffffff',['0xFF3E3E40','0xFF202123','0xFF5E5C5C','0xFF82817F','0xFFA1A9AB','0xFFCDD2CE','0xFF7393AF','0xFF516E8A']],
//  ['Goat 3',10,'0xFFffffff',['0xFF3E3E40','0xFF202123','0xFF5E5C5C','0xFF82817F','0xFFA1A9AB','0xFFCDD2CE','0xFF7393AF','0xFF516E8A','0xFF61493F','0xFF8D7569']],
  //['Maits Stairs',10,'0xFFffffff',['0xFF5F6F82','0xFF393A37','0xFF52575A','0xFF1F1E1A','0xFFDCDAC7','0xFFCDC6AC','0xFFEAE9D9','0xFFB9B193','0xFF99937E','0xFF81755A']],
  //['Lilly',8,'0xFFffffff',['0xFFBEBFB1','0xFF273313','0xFFA9A894','0xFF807550','0xFF3F4B22','0xFF513C07','0xFFB3770D','0xFF101C09']],
  //['Man in blue hat',10,'0xFFffffff',['0xFF181714','0xFF1F1E1A','0xFF2A2822','0xFF5E6160','0xFF3D372E','0xFF494C4B','0xFFE5E6E2','0xFFD8BEA9','0xFFB58B71','0xFF919FBB']],
  //['Spider',10,'0xFFffffff',['0xFFA7A98D','0xFF94957A','0xFF818168','0xFF6F6B58','0xFF5B5147','0xFF2D1D19','0xFFBDBFA3','0xFF0F0C08','0xFF473631','0xFFE3E3D4']],
  [
    'Deck Chairs',
    7,
    '0xFFffffff',
    [
      '0xFFEDEFEE',
      '0xFF8E6C53',
      '0xFFDDCFB6',
      '0xFFBB9E7F',
      '0xFFAA1C10',
      '0xFF5F3C28',
      '0xFF8CCDEE'
    ]
  ],
  [
    'Bo Kaap',
    10,
    '0xFFffffff',
    [
      '0xFFC05655',
      '0xFFD5CF5C',
      '0xFFC0B1B8',
      '0xFF776B52',
      '0xFF97969B',
      '0xFF563345',
      '0xFF441D21',
      '0xFF0F4C69',
      '0xFF5083AD',
      '0xFFE4E4DE'
    ]
  ],
  [
    'Pantone Pop Stripes',
    13,
    '0xFFffffff',
    [
      '0xFFBF5E02',
      '0xFFA2B035',
      '0xFFD0920A',
      '0xFF718FBF',
      '0xFFE4C91C',
      '0xFF082670',
      '0xFF6D041F',
      '0xFF4F3820',
      '0xFFE0C9CC',
      '0xFFE3C9CA',
      '0xFF8D1C15',
      '0xFFABC8CA',
      '0xFFE27000'
    ]
  ],
  [
    'Purple Artichokes',
    16,
    '0xFFffffff',
    [
      '0xFF907B8E',
      '0xFFAB96AF',
      '0xFFD7DAD8',
      '0xFFC3B3CF',
      '0xFF79736D',
      '0xFFB5C0B1',
      '0xFF97A389',
      '0xFF5E4E54',
      '0xFF3A342D',
      '0xFFEBF8F5',
      '0xFF9CA693',
      '0xFF6F855E',
      '0xFF899775',
      '0xFFD8E1D6',
      '0xFF91C0AB',
      '0xFF6BA381'
    ]
  ],
  [
    'Stained Glass',
    10,
    '0xFFffffff',
    [
      '0xFF160716',
      '0xFF491A2D',
      '0xFFE9BD33',
      '0xFF412A67',
      '0xFF5F519E',
      '0xFF8A4946',
      '0xFF6D80DA',
      '0xFFC58CA8',
      '0xFFCF2C6E',
      '0xFFF1E6E4'
    ]
  ],
  [
    'Ferns',
    10,
    '0xFFffffff',
    [
      '0xFF4B4810',
      '0xFF9AA93A',
      '0xFF828D29',
      '0xFF343008',
      '0xFF5C5428',
      '0xFF746E38',
      '0xFF686D17',
      '0xFF181801',
      '0xFFB1C053',
      '0xFF8F8A4E'
    ]
  ],
  [
    'Rhubarb',
    7,
    '0xFFffffff',
    [
      '0xFFB93A3D',
      '0xFFAE3E20',
      '0xFFA32323',
      '0xFF821107',
      '0xFF8A1210',
      '0xFFC45A2E',
      '0xFFD1605D'
    ]
  ],
  [
    'SriDevi',
    10,
    '0xFFffffff',
    [
      '0xFF884761',
      '0xFF723A4D',
      '0xFFA04F71',
      '0xFFBD9E79',
      '0xFFBEA592',
      '0xFFAA707A',
      '0xFFAB8F70',
      '0xFFB9858A',
      '0xFF936669',
      '0xFFCCBEAF'
    ]
  ],
  [
    'Peacock',
    15,
    '0xFFffffff',
    [
      '0xFF55773E',
      '0xFF355523',
      '0xFF779758',
      '0xFF172C12',
      '0xFF8DC773',
      '0xFFBAE898',
      '0xFFE6F3CB',
      '0xFFC4A983',
      '0xFF30A4D7',
      '0xFF1E477C',
      '0xFF111832',
      '0xFF16B2D5',
      '0xFF28A95E',
      '0xFFEFDA58',
      '0xFFA72F2B',
      '0xFFB8B01E'
    ]
  ],
  [
    'Coronavirus',
    8,
    '0xFFffffff',
    [
      '0xFF1B1919',
      '0xFF641C19',
      '0xFF922F2E',
      '0xFF8C837E',
      '0xFFB8A49C',
      '0xFFBE4F4D',
      '0xFF695C57',
      '0xFFDDD3CB'
    ]
  ],
];

class OpArtPalette {
  String paletteName = 'Default';
  List<Color> colorList = const [
    Color(0xFF34a1af),
    Color(0xFFa570a8),
    Color(0xFFd6aa27),
    Color(0xFF5f9d50),
    Color(0xFF789dd1),
    Color(0xFFc25666),
    Color(0x0ff2b7b1),
    Color(0x0ffd63aa),
    Color(0x0ff1f4ed),
    Color(0xFF383c47)
  ];
  String paletteType = 'random';

  void randomize(String paletteType, int numberOfColours) {
    // print('paletteType: $paletteType');
    // print('numberOfColours: $numberOfColours');

    // seed = DateTime.now().millisecond;
    final Random rnd = Random(seed);
    // print('randomizing palette');

    final List<Color> palette = [];

    switch (paletteType) {
      // random
      case 'random':
        {
          for (int colorIndex = 0; colorIndex < numberOfColours; colorIndex++) {
            palette.add(
                Color((rnd.nextDouble() * 0xFFFFFF).toInt()).withOpacity(1));
          }
        }

      // blended random
      case 'blended random':
        {
          final Color blendColour = Color(rnd.nextInt(0xFFFFFF)).withOpacity(1);
          palette.add(blendColour);
          for (int colourIndex = 1;
              colourIndex < numberOfColours;
              colourIndex++) {
            final Color randomColor = Color(rnd.nextInt(0xFFFFFF));
            palette.add(Color.fromARGB(
                (blendColour.alpha * 2 + randomColor.alpha) ~/ 3,
                (blendColour.red * 2 + randomColor.red) ~/ 3,
                (blendColour.green * 2 + randomColor.green) ~/ 3,
                (blendColour.blue * 2 + randomColor.blue) ~/ 3));
          }
        }

      // linear random
      case 'linear random':
        {
          final List startColour = [
            rnd.nextInt(255),
            rnd.nextInt(255),
            rnd.nextInt(255)
          ];
          final List endColour = [
            rnd.nextInt(255),
            rnd.nextInt(255),
            rnd.nextInt(255)
          ];
          for (int colourIndex = 0;
              colourIndex < numberOfColours;
              colourIndex++) {
            palette.add(Color.fromRGBO(
                ((startColour[0] * colourIndex +
                            endColour[0] * (numberOfColours - colourIndex)) /
                        numberOfColours)
                    .round() as int,
                ((startColour[1] * colourIndex +
                            endColour[1] * (numberOfColours - colourIndex)) /
                        numberOfColours)
                    .round() as int,
                ((startColour[2] * colourIndex +
                            endColour[2] * (numberOfColours - colourIndex)) /
                        numberOfColours)
                    .round() as int,
                1));
          }
        }

      // linear complementary
      case 'linear complementary':
        {
          final List startColour = [
            rnd.nextInt(255),
            rnd.nextInt(255),
            rnd.nextInt(255)
          ];
          final List endColour = [
            255 - (startColour[0] as num),
            255 - (startColour[1] as num),
            255 - (startColour[2] as num)
          ];
          for (int colourIndex = 0;
              colourIndex < numberOfColours;
              colourIndex++) {
            palette.add(Color.fromRGBO(
                ((startColour[0] * colourIndex +
                            endColour[0] * (numberOfColours - colourIndex)) /
                        numberOfColours)
                    .round() as int,
                ((startColour[1] * colourIndex +
                            endColour[1] * (numberOfColours - colourIndex)) /
                        numberOfColours)
                    .round() as int,
                ((startColour[2] * colourIndex +
                            endColour[2] * (numberOfColours - colourIndex)) /
                        numberOfColours)
                    .round() as int,
                1));
          }
        }
    }

    colorList = palette;
  }
}
