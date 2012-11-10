<- (angular.module \ace []).directive \ace

load-ace-editor = (element, mode, is-read-only) ->
    editor = window.ace.edit (($ element).find '.' + ACE_EDITOR_CLASS).0
    editor.session.set-mode "ace/mode/#mode"
    editor.renderer.set-show-print-margin false
    editor.set-read-only is-read-only
    editor

const ACE_EDITOR_CLASS = \ace-editor

return {
    restrict: \A
    require: \?ngModel
    transclude: yes
    template: "<div class='transcluded' ng-transclude></div><div class='#ACE_EDITOR_CLASS'></div>"
    link: (scope, element, {ace: mode, id: editor_id}, ng-model) ->
        rightEditorChangeHandler = -> $ \#left_arrow .fade-in!
        leftEditorChangeHandler = -> read!
        read = ->
            if ng-model
                ng-model.$set-view-value editor.get-value!
                textarea.val editor.get-value!
            cs = ''
            $ err .html '' .hide!
            switch editor_id
            | \cs2lslefteditor
                cs = editor.get-value!
            | \js2lslefteditor
                try cs = Js2coffee.build editor.get-value!
                catch => $ err .html "#e" .show!
            | \js2lsrighteditor
                try cs = Js2coffee.build scope.js2lslefteditor.get-value!
                catch => $ err .html "#e" .show!
            | \cs2lsrighteditor
                cs = scope.cs2lslefteditor.get-value!
            return if cs is /^\s*(#\s*.*)?\s*$/
            ls = ''
            try ls = coffee2ls.compile coffee2ls.parse cs
            catch e
                $ err
                    .html ''
                    .append $(\<pre/>).css('text-align', 'left').text e
                    .show!
                return
            switch editor_id
            | <[ js2lslefteditor js2lsrighteditor ]>
                unless (editor_id is 'js2lslefteditor' and scope.righteditor_changed)
                    try scope.js2lsrighteditor.get-session!.set-value ls
                    $ \#left_arrow .hide!
                scope.righteditor_changed is false
            | <[ cs2lslefteditor cs2lsrighteditor ]>
                try scope.cs2lsrighteditor.get-session!.set-value ls
        textarea = $ element .find \textarea .hide!
        editor = switch editor_id
            | <[ js2lslefteditor js2lsrighteditor cs2lslefteditor ]>
                load-ace-editor element, mode, false
            | \cs2lsrighteditor
                load-ace-editor element, mode, true

        err = switch editor_id
            | <[ js2lslefteditor js2lsrighteditor ]> => \#js2lserror
            | <[ cs2lslefteditor cs2lsrighteditor ]> => \#cs2lserror

        scope.ace = scope[editor_id] = editor

        unless ng-model
            read!
            if editor_id is \js2lsrighteditor
                editor.get-session!on \change rightEditorChangeHandler
            return

        ng-model.$render = ->
            value = ng-model.$viewValue || ''
            editor.get-session!.set-value value
            textarea.val value
        editor.get-session!.on \change leftEditorChangeHandler
        editor.get-session!.set-value textarea.val!
        read!
}
