module.exports =
  cleanExtensions:
    type: 'array'
    default: [
        '.aux'
        '.bbl'
        '.blg'
        '.fdb_latexmk'
        '.fls'
        '.log'
        '.out'
        '.pdf'
        '.synctex.gz'
      ]
    items:
      type: 'string'

  customEngine:
    description: 'Enter command for custom LaTeX engine. Overrides Engine.'
    type: 'string'
    default: ''

  enableShellEscape:
    type: 'boolean'
    default: false

  engine:
    description: 'Select standard LaTeX engine'
    type: 'string'
    default: 'pdflatex'
    enum: ['pdflatex', 'lualatex', 'xelatex']

  moveResultToSourceDirectory:
    title: 'Move Result to Source Directory'
    description: 'Ensures that the output file produced by a successful build
      is stored together with the TeX document that produced it.'
    type: 'boolean'
    default: true

  openResultAfterBuild:
    title: 'Open Result after Successful Build'
    type: 'boolean'
    default: true

  openResultInBackground:
    title: 'Open Result in Background'
    type: 'boolean'
    default: true

  outputDirectory:
    description: 'All files generated during a build will be redirected here.
      Leave blank if you want the build output to be stored in the same
      directory as the TeX document.'
    type: 'string'
    default: ''

  skimPath:
    description: 'Full application path to Skim (OS X).'
    type: 'string'
    default: '/Applications/Skim.app'

  sumatraPath:
    title: 'SumatraPDF Path'
    description: 'Full application path to SumatraPDF (Windows).'
    type: 'string'
    default: 'C:\\Program Files\\SumatraPDF\\SumatraPDF.exe'

  texPath:
    title: 'TeX Path'
    description: "The full path to your TeX distribution's bin directory."
    type: 'string'
    default: ''
