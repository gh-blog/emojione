through2 = require 'through2'
fs = require 'fs'
vm = require 'vm'
File = require 'vinyl'
emojioneFile = "#{__dirname}/node_modules/emojione/lib/js/emojione.min.js"
cssFile = "#{__dirname}/node_modules/emojione/assets/css/emojione.min.css"

module.exports = (options) ->
    sandbox = { }
    vm.runInNewContext (fs.readFileSync emojioneFile), sandbox

    { emojione } = sandbox
    emojione.imageType = 'svg'
    # used_emojis = {  } # Index by unicode character?

    processFile = (file, enc, done) ->
        if file.isPost and file.$
            $root = file.$.root()
            $root.html emojione.toImage $root.html()

            file.$('.emojione').addClass 'emoji'

            file.contents = new Buffer file.$.html()
            file.styles.push '/styles/emojione.min.css'

        done null, file

    through2.obj processFile, (done) ->
        # @TODO: push all the emojis
        @push new File {
            path: '../styles/emojione.min.css'
            contents: fs.readFileSync cssFile
        }
        done()