helpers = require './spec-helpers'
fs = require 'fs-plus'
path = require 'path'
latex = require '../lib/latex'
LatexmkBuilder = require '../lib/builders/latexmk'

describe "Latex", ->
  [fixturesPath] = []

  beforeEach ->
    fixturesPath = helpers.cloneFixtures()

  describe "build", ->
    [originalTimeoutInterval] = []

    beforeEach ->
      originalTimeoutInterval = helpers.setTimeoutInterval(10000)

      spyOn(latex, 'showResult').andCallThrough()
      spyOn(latex, 'getOpener').andReturn()

    afterEach ->
      helpers.setTimeoutInterval(originalTimeoutInterval)

    it "does nothing for new, unsaved files", ->
      spyOn(latex, 'build').andCallThrough()
      spyOn(latex, 'showError').andCallThrough()

      [result] = []
      waitsForPromise ->
        atom.workspace.open()

      runs ->
        result = latex.build()

      waitsFor ->
        latex.build.callCount == 1

      runs ->
        expect(result).toBe false
        expect(latex.showResult).not.toHaveBeenCalled()
        expect(latex.showError).not.toHaveBeenCalled()

    it "does nothing for unsupported file extensions", ->
      spyOn(latex, 'build').andCallThrough()
      spyOn(latex, 'showError').andCallThrough()

      [editor, result] = []
      waitsForPromise ->
        atom.workspace.open('file.md').then (ed) -> editor = ed

      runs ->
        editor.save()
        result = latex.build()

      waitsFor ->
        latex.build.callCount == 1

      runs ->
        expect(result).toBe false
        expect(latex.showResult).not.toHaveBeenCalled()
        expect(latex.showError).not.toHaveBeenCalled()

    it "runs `latexmk` for existing files", ->
      waitsForPromise ->
        atom.workspace.open('file.tex')

      runs ->
        latex.build()

      waitsFor ->
        latex.showResult.callCount == 1

      runs ->
        expect(latex.showResult).toHaveBeenCalled()

    it "saves the file before building, if modified", ->
      [editor] = []
      waitsForPromise ->
        atom.workspace.open('file.tex').then (ed) -> editor = ed

      runs ->
        editor.moveToBottom()
        editor.insertNewline()
        latex.build()

      waitsFor ->
        latex.showResult.callCount == 1

      runs ->
        expect(editor.isModified()).toEqual(false)

    it "supports paths containing spaces", ->
      waitsForPromise ->
        atom.workspace.open('filename with spaces.tex')

      runs ->
        latex.build()

      waitsFor ->
        latex.showResult.callCount == 1

      runs ->
        expect(latex.showResult).toHaveBeenCalled()

    it "invokes `showResult` after a successful build, with expected log parsing result", ->
      waitsForPromise ->
        atom.workspace.open('file.tex')

      runs ->
        latex.build()

      waitsFor ->
        latex.showResult.callCount == 1

      runs ->
        expect(latex.showResult).toHaveBeenCalledWith {
          outputFilePath: path.join(fixturesPath, 'file.pdf')
          errors: []
          warnings: []
        }

    it "treats missing output file data in log file as an error", ->
      class MockBuilder extends LatexmkBuilder
        parseLogFile: (texFilePath) ->
          result =
            outputFilePath: null
            errors: []
            warnings: []

      spyOn(latex, 'getBuilder').andReturn(new MockBuilder())
      spyOn(latex, 'showError').andCallThrough()

      waitsForPromise ->
        atom.workspace.open('file.tex')

      runs ->
        latex.build()

      waitsFor ->
        latex.showError.callCount == 1

      runs ->
        expect(latex.showError).toHaveBeenCalled()

  describe "getOpener", ->
    originalPlatform = process.platform

    afterEach ->
      helpers.overridePlatform(originalPlatform)

    it "supports OS X", ->
      helpers.overridePlatform('darwin')
      opener = latex.getOpener()

      expect(opener.constructor.name).toEqual('PreviewOpener')

    it "does not support GNU/Linux", ->
      helpers.overridePlatform('linux')
      opener = latex.getOpener()

      expect(opener).toBeUndefined()

    it "does not support Windows", ->
      helpers.overridePlatform('win32')
      opener = latex.getOpener()

      expect(opener).toBeUndefined()

    it "does not support unknown operating system", ->
      helpers.overridePlatform('foo')
      opener = latex.getOpener()

      expect(opener).toBeUndefined()

    it "returns SkimOpener when installed on OS X", ->
      atom.config.set('latex.skimPath', '/Applications/Skim.app')
      helpers.overridePlatform('darwin')

      existsSync = fs.existsSync
      spyOn(fs, 'existsSync').andCallFake (filePath) ->
        return true if filePath is '/Applications/Skim.app'
        existsSync(filePath)

      opener = latex.getOpener()

      expect(opener.constructor.name).toEqual('SkimOpener')

    it "returns PreviewOpener when Skim is not installed on OS X", ->
      atom.config.set('latex.skimPath', '/foo/Skim.app')
      helpers.overridePlatform('darwin')
      opener = latex.getOpener()

      expect(opener.constructor.name).toEqual('PreviewOpener')
