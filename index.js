// Compiled by Koding Servers at Fri Apr 12 2013 12:34:33 GMT-0700 (PDT) in server time

(function() {

/* KDAPP STARTS */

/* BLOCK STARTS /Source: /Users/arvidkahl/Applications/kodelectures.kdapp/app/settings.coffee */

var KodeLectures, cowExamples, example, examples, _i, _len;

KodeLectures = {
  Settings: {
    theme: "ace/theme/monokai",
    exampleCode: null,
    exampleCSS: null,
    aceThrottle: 400
  },
  Core: {
    Utils: null,
    LiveViewer: null,
    AppCreator: null
  },
  Views: {
    Editor: null,
    MainView: null
  }
};

KodeLectures.Settings.lectures = [];

examples = [
  {
    "title": "Lecture 1: Console.log and Boolean values",
    "summary": "In this lecture, you will learn about Console and Booleans.",
    "expectedResults": "true",
    "submitSuccess": "Well done! You can procedd to the next part, where you will learn all about infinite loops.",
    "submitFailure": "This is not the statement we are looking for.",
    "language": "javascript",
    "code": "// Hey there! enter your code here, please.\n\n// To log something to the console, you can use the properties of the console object\n// e.g. console.warn, console.error and so on...",
    "codeHint": "\nThere are two Boolean values, `true` and `false`. The easiest way of logging a true value to the console is:\n\n```js\nconsole.log(true)\n```\n\nBut any truthy expression would do the trick, such as\n\n```js\nconsole.log(1==1)\n```\n\nor\n\n```js\nconsole.log(!(false && (1+2!==Infinity)))\n```\n\nBoth evaluate to `true` before being logged to the console.\n",
    "codeHintText": "`Console.log()` prints to the console. Javascript knows only one truly true statement. That would be `true`.",
    "taskText": "#Hello\n\nWelcome to the Lecture. Today we'll be learning about Boolean values. Named after [George Boole](http://en.wikipedia.org/wiki/George_Boole), these values are logical representations of Truth of Falsehood. Since there is nothing in between, only two mutually exclusive values exist in JavaScript, `true` and `false`.\n\nThere is also an  Object type called Boolean, which can take these values. It also supplies a few methods. But more on that later!\n\nTry printing a true statement to the console."
  }, {
    "title": "Lecture 2: While loops",
    "summary": "This lecture is about loops",
    "expectedResults": "1\n2\n3\n4\n5",
    "submitSuccess": "Well done! You can procedd to the next part, where you will learn all more things.",
    "submitFailure": "This is not the statement we are looking for.",
    "language": "javascript",
    "code": "// There are many ways to loop in JavaScript.\n//Try using while() in this assignment. We'll get to the other ones later.",
    "codeHint": "\nOne way to use a while loop would be:\n\n```js\nvar i = 1;\nwhile(i<6){\n  console.log(i++);\n}\n```",
    "codeHintText": "You might want to instantiate a variable, and increase its value one by one. And make sure to stop at some point. Maybe with a comparison?",
    "taskText": "# What does it do?\n\nCreates a loop that executes a specified statement as long as the test condition evaluates to true. The condition is evaluated before executing the statement.\n\n##How do I use it?\n\n```js\nwhile (condition) {\n  statement\n}\n```\n\n- `condition`\n  - An expression evaluated before each pass through the loop. If this condition evaluates to true, statement is executed. When condition evaluates to false, execution continues with the statement after the while loop.\n- `statement`\n  - A statement that is executed as long as the condition evaluates to true. To execute multiple statements within the loop, use a block statement ({ ... }) to group those statements.\n\n##What you should do\nPrint the numbers `1` to `5` to the console, using a while loop."
  }, {
    "title": "Lecture 3: A glimpse of CoffeeScript",
    "summary": "Here comes CoffeeScript",
    "expectedResults": "This is CoffeeScript",
    "submitSuccess": "Well done! You can procedd to the next part, where you will learn all more things.",
    "submitFailure": "This is not the statement we are looking for.",
    "language": "coffee",
    "code": "# Woah, what is this?\n# Well it's CoffeeScript, a language that compiles to JavaScript but is so much easier to write.\n\n# Don't believe me? Check this out:\n\n\nconsole.log name.toUpperCase() for name in ['Alice','Bob','Malice']",
    "codeHint": "\n```js\nvar i = 1;\nwhile(i<6){\n  console.log(i++);\n}\n```",
    "codeHintText": "Do something with console.log",
    "taskText": "# CoffeeScript\n\n**CoffeeScript is a little language that compiles into JavaScript**. Underneath that awkward Java-esque patina, JavaScript has always had a gorgeous heart. CoffeeScript is an attempt to expose the good parts of JavaScript in a simple way.\n\n\nThe golden rule of CoffeeScript is: \"It's just JavaScript\". The code compiles one-to-one into the equivalent JS, and there is no interpretation at runtime. You can use any existing JavaScript library seamlessly from CoffeeScript (and vice-versa). The compiled output is readable and pretty-printed, passes through JavaScript Lint without warnings, will work in every JavaScript runtime, and tends to run as fast or faster than the equivalent handwritten JavaScript.\n\n\nLatest Version: 1.6.2"
  }
];

cowExamples = [
  {
    "title": "A cow and how to tip it",
    "summary": "Cow handling procedures",
    "expectedResults": "Cow",
    "submitSuccess": "Well done! You can procedd to the next part, where you will learn all more things.",
    "submitFailure": "This is not the statement we are looking for.",
    "language": "coffee",
    "code": "cow",
    "codeHintText": "Do something with the cow",
    "taskText": "When fighting cows, take care."
  }
];

KodeLectures.Settings.lectures.push({
  title: 'JavaScript 101',
  lectures: []
});

for (_i = 0, _len = examples.length; _i < _len; _i++) {
  example = examples[_i];
  KodeLectures.Settings.lectures[0].lectures.push(example);
}

KodeLectures.Settings.lectures.push({
  title: 'How to ride a cow',
  lectures: []
});

KodeLectures.Settings.lectures[1].lectures.push(cowExamples[0]);


/* BLOCK ENDS */



/* BLOCK STARTS /Source: /Users/arvidkahl/Applications/kodelectures.kdapp/app/core.coffee */

var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

KodeLectures.Core.Utils = (function() {
  var _this = this;

  function Utils() {}

  Utils.notify = function(message) {
    var _ref;

    if ((_ref = Utils.instance) != null) {
      _ref.destroy();
    }
    return Utils.instance = new KDNotificationView({
      type: "mini",
      title: message
    });
  };

  return Utils;

}).call(this);

KodeLectures.Core.LiveViewer = (function() {
  var notify;

  notify = KodeLectures.Core.Utils.notify;

  LiveViewer.getSingleton = function() {
    var _ref;

    return (_ref = LiveViewer.instance) != null ? _ref : LiveViewer.instance = new LiveViewer;
  };

  LiveViewer.prototype.active = false;

  LiveViewer.prototype.pistachios = /\{(\w*)?(\#\w*)?((?:\.\w*)*)(\[(?:\b\w*\b)(?:\=[\"|\']?.*[\"|\']?)\])*\{([^{}]*)\}\s*\}/g;

  function LiveViewer() {
    this.sessionId = KD.utils.uniqueId("kodepadSession");
  }

  LiveViewer.prototype.setPreviewView = function(previewView) {
    this.previewView = previewView;
    if (!this.mdPreview) {
      return this.previewView.addSubView(this.mdPreview = new KDView({
        cssClass: 'has-markdown markdown-preview',
        partial: '<div class="info"><pre>When you run your code, you will see the results here</pre></div>'
      }));
    }
  };

  LiveViewer.prototype.setSplitView = function(splitView) {
    this.splitView = splitView;
  };

  LiveViewer.prototype.setMainView = function(mainView) {
    this.mainView = mainView;
  };

  LiveViewer.prototype.previewCode = function(code, options) {
    var command, kiteController,
      _this = this;

    if (options == null) {
      options = {};
    }
    if (!this.active) {
      return;
    }
    if (!(!code || code === '')) {
      kiteController = KD.getSingleton("kiteController");
      command = (function() {
        switch (this.mainView.currentLang) {
          case 'javascript':
            return "echo '" + (window.btoa(code)) + "' | base64 -d > temp.js; node temp.js;";
          case 'coffee':
            return "echo '" + (window.btoa(code)) + "' | base64 -d > temp.coffee; coffee temp.coffee -n;";
          case 'ruby':
            return "echo '" + (window.btoa(code)) + "' | base64 -d > temp.rb; ruby temp.rb;";
          case 'python':
            return "echo '" + (window.btoa(code)) + "' | base64 -d > temp.py; python temp.py;";
        }
      }).call(this);
      return kiteController.run(command, function(err, res) {
        var error, text;

        if (!err) {
          _this.mainView.taskView.emit('ResultReceived', res);
        }
        if (res === '') {
          text = '<div class="info"><pre>KodeLectures received an empty response but no error.</pre></div>';
        } else {
          text = err ? "<div class='error'><pre>" + err.message + "</pre></div>" : "<div class='success'><pre>" + res + "</pre></div>";
        }
        window.appView = _this.previewView;
        try {
          if (!_this.mdPreview) {
            return _this.previewView.addSubView(_this.mdPreview = new KDView({
              cssClass: 'has-markdown markdown-preview',
              partial: text
            }));
          } else {
            return _this.mdPreview.updatePartial(text);
          }
        } catch (_error) {
          error = _error;
          return notify(error.message);
        } finally {
          delete window.appView;
        }
      });
    }
  };

  LiveViewer.prototype.previewCSS = function(code) {
    var css, session;

    if (!this.active) {
      return;
    }
    session = "__kodepadCSS" + this.sessionId;
    if (window[session]) {
      try {
        window[session].remove();
      } catch (_error) {}
    }
    css = $("<style scoped></style>");
    css.html(code);
    window[session] = css;
    return this.previewView.domElement.prepend(window[session]);
  };

  return LiveViewer;

}).call(this);

KodeLectures.Core.AppCreator = (function() {
  var notify;

  function AppCreator() {}

  notify = KodeLectures.Core.Utils.notify;

  AppCreator.getSingleton = function() {
    var _ref;

    return (_ref = AppCreator.instance) != null ? _ref : AppCreator.instance = new AppCreator;
  };

  AppCreator.prototype.manifestTemplate = function(appName) {
    var firstName, lastName, nickname, _ref;

    _ref = KD.whoami().profile, firstName = _ref.firstName, lastName = _ref.lastName, nickname = _ref.nickname;
    return {
      manifest: "{\n  \"devMode\": true,\n  \"version\": \"0.1\",\n  \"name\": \"" + appName + "\",\n  \"identifier\": \"com.koding." + nickname + ".apps." + (appName.toLowerCase()) + "\",\n  \"path\": \"~/Applications/" + appName + ".kdapp\",\n  \"homepage\": \"" + nickname + ".koding.com/" + appName + "\",\n  \"author\": \"" + firstName + " " + lastName + "\",\n  \"repository\": \"git://github.com/" + nickname + "/" + appName + ".kdapp.git\",\n  \"description\": \"" + appName + " : a Koding application created with the Kodepad.\",\n  \"category\": \"web-app\",\n  \"source\": {\n    \"blocks\": {\n      \"app\": {\n        \"files\": [\n          \"./index.coffee\"\n        ]\n      }\n    },\n    \"stylesheets\": [\n      \"./resources/style.css\"\n    ]\n  },\n  \"options\": {\n    \"type\": \"tab\"\n  },\n  \"icns\": {\n    \"128\": \"./resources/icon.128.png\"\n  }\n}"
    };
  };

  AppCreator.prototype.create = function(name, coffee, css, callback) {
    var appPath, basePath, coffeeFile, commands, cssFile, finder, kite, manifest, manifestFile, nickname, skeleton, tree;

    manifest = this.manifestTemplate(name).manifest;
    nickname = KD.whoami().profile.nickname;
    kite = KD.getSingleton('kiteController');
    finder = KD.getSingleton("finderController");
    tree = finder.treeController;
    appPath = "/Users/" + nickname + "/Applications";
    basePath = "" + appPath + "/" + name + ".kdapp";
    coffeeFile = "" + basePath + "/index.coffee";
    cssFile = "" + basePath + "/resources/style.css";
    manifestFile = "" + basePath + "/.manifest";
    commands = ["mkdir -p " + basePath, "mkdir -p " + basePath + "/resources", "curl -kL https://koding.com/images/default.app.thumb.png -o " + basePath + "/resources/icon.128.png"];
    skeleton = commands.join(";");
    return kite.run(skeleton, function(error, response) {
      var coffeeFileInstance, cssFileInstance, manifestFileInstance;

      if (error) {
        return;
      }
      coffeeFileInstance = FSHelper.createFileFromPath(coffeeFile);
      coffeeFileInstance.save(coffee);
      cssFileInstance = FSHelper.createFileFromPath(cssFile);
      cssFileInstance.save(css);
      manifestFileInstance = FSHelper.createFileFromPath(manifestFile);
      manifestFileInstance.save(manifest);
      return KD.utils.wait(1000, function() {
        tree.refreshFolder(tree.nodes[appPath]);
        KD.getSingleton('kodingAppsController').refreshApps();
        return callback();
      });
    });
  };

  AppCreator.prototype.createGist = function(coffee, css, callback) {
    var gist, kite, nickname;

    nickname = KD.whoami().profile.nickname;
    gist = {
      description: "Kodepad Gist Share by " + nickname + " on http://koding.com\nAuthor: http://" + nickname + ".koding.com",
      "public": true,
      files: {
        "index.coffee": {
          content: coffee
        },
        "style.css": {
          content: css
        }
      }
    };
    kite = KD.getSingleton('kiteController');
    return kite.run("mkdir -p /Users/" + nickname + "/.kodepad", function(err, res) {
      var tmp, tmpFile;

      tmpFile = "/Users/" + nickname + "/.kodepad/.gist.tmp";
      tmp = FSHelper.createFileFromPath(tmpFile);
      return tmp.save(JSON.stringify(gist), function(err, res) {
        if (err) {
          return;
        }
        return kite.run("curl -kL -A\"Koding\" -X POST https://api.github.com/gists --data @" + tmpFile, function(err, res) {
          callback(err, JSON.parse(res));
          return kite.run("rm -f " + tmpFile);
        });
      });
    });
  };

  return AppCreator;

}).call(this);

KodeLectures.Views.HelpView = (function(_super) {
  __extends(HelpView, _super);

  function HelpView() {
    HelpView.__super__.constructor.apply(this, arguments);
  }

  HelpView.prototype.setDefault = function() {};

  HelpView.prototype.pistachio = function() {
    return "";
  };

  return HelpView;

})(JView);

KodeLectures.Views.TaskView = (function(_super) {
  __extends(TaskView, _super);

  TaskView.prototype.setMainView = function(mainView) {
    this.mainView = mainView;
  };

  function TaskView() {
    var _this = this;

    TaskView.__super__.constructor.apply(this, arguments);
    this.setClass('task-view');
    this.nextLectureButton = new KDButtonView({
      title: 'Next Lecture',
      cssClass: 'cupid-green hidden fr task-next-button',
      callback: function() {
        return _this.mainView.emit('NextLectureRequested');
      }
    });
    this.taskTextView = new KDView({
      cssClass: 'task-text-view has-markdown',
      partial: "<span class='text'>Assignment</span><span class='data'>" + (marked(this.getData().taskText)) + "</span>"
    });
    this.resultView = new KDView({
      cssClass: 'result-view hidden'
    });
    this.hintView = new KDView({
      cssClass: 'hint-view has-markdown',
      partial: '<span class="text">Show hint</span>',
      click: function() {
        return _this.hintView.updatePartial("<span class='text'>Hint</span><span class='data'>" + (marked(_this.getData().codeHintText)) + "</span>");
      }
    });
    this.hintCodeView = new KDView({
      cssClass: 'hint-code-view has-markdown',
      partial: '<span class="text">Show solution</span>',
      click: function() {
        return _this.hintCodeView.updatePartial("<span class='text'>Solution</span><span class='data'>" + (marked(_this.getData().codeHint)) + "</span>");
      }
    });
    this.on('LectureChanged', function(lecture) {
      var _ref;

      _this.setData(lecture);
      _this.resultView.hide();
      _this.nextLectureButton.hide();
      _this.mainView.liveViewer.active = false;
      if ((_ref = _this.mainView.liveViewer.mdPreview) != null) {
        _ref.updatePartial('<div class="info"><pre>When you run your code, you will see the results here</pre></div>');
      }
      _this.taskTextView.updatePartial("<span class='text'>Assignment</span><span class='data'>" + (marked(_this.getData().taskText)) + "</span>");
      _this.hintView.updatePartial('<span class="text">Show hint</span>');
      _this.hintCodeView.updatePartial('<span class="text">Show solution</span>');
      return _this.render();
    });
    this.on('ResultReceived', function(result) {
      _this.resultView.show();
      if (result.trim() === _this.getData().expectedResults) {
        _this.resultView.updatePartial(_this.getData().submitSuccess);
        _this.resultView.setClass('success');
        return _this.nextLectureButton.show();
      } else {
        _this.resultView.updatePartial(_this.getData().submitFailure);
        return _this.resultView.unsetClass('success');
      }
    });
  }

  TaskView.prototype.pistachio = function() {
    return "{{> this.nextLectureButton}}\n{{> this.resultView}}    \n\n{{> this.taskTextView}}\n\n{{> this.hintView}}\n{{> this.hintCodeView}}";
  };

  return TaskView;

})(JView);

KodeLectures.Views.TaskOverviewListItemView = (function(_super) {
  __extends(TaskOverviewListItemView, _super);

  function TaskOverviewListItemView() {
    var summary, title, _ref;

    TaskOverviewListItemView.__super__.constructor.apply(this, arguments);
    this.setClass('task-overview-item has-markdown');
    _ref = this.getData(), title = _ref.title, summary = _ref.summary;
    this.titleText = new KDView({
      cssClass: 'title-text',
      partial: marked(title)
    });
    this.summaryText = new KDView({
      partial: marked(summary)
    });
  }

  TaskOverviewListItemView.prototype.pistachio = function() {
    return "<span class='data'>\n{{> this.titleText}}\n</span>\n<div class='summary'>\n  <span class='data'>\n  {{> this.summaryText}}\n  </span>\n</div>";
  };

  TaskOverviewListItemView.prototype.click = function() {
    return this.getDelegate().emit('OverviewLectureClicked', this);
  };

  TaskOverviewListItemView.prototype.viewAppended = function() {
    this.setTemplate(this.pistachio());
    return this.template.update();
  };

  return TaskOverviewListItemView;

})(KDListItemView);

KodeLectures.Views.TaskOverview = (function(_super) {
  var TaskOverviewListItemView;

  __extends(TaskOverview, _super);

  TaskOverviewListItemView = KodeLectures.Views.TaskOverviewListItemView;

  function TaskOverview() {
    var _this = this;

    TaskOverview.__super__.constructor.apply(this, arguments);
    this.setClass('task-overview');
    this.lectureListController = new KDListViewController({
      itemClass: TaskOverviewListItemView,
      delegate: this
    }, {
      items: this.getData()
    });
    this.lectureList = this.lectureListController.getView();
    this.lectureListController.listView.on('OverviewLectureClicked', function(item) {
      _this.mainView.exampleCode.setValue(_this.lectureListController.itemsOrdered.indexOf(item));
      return _this.mainView.emit('LectureChanged', _this.lectureListController.itemsOrdered.indexOf(item));
    });
    this.on('LectureChanged', function(_arg) {
      var course, index, item, _i, _len, _ref;

      course = _arg.course, index = _arg.index;
      _this.lectureListController.removeAllItems();
      _this.lectureListController.instantiateListItems(course.lectures);
      _ref = _this.lectureListController.itemsOrdered;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        item.unsetClass('active');
      }
      return _this.lectureListController.itemsOrdered[index].setClass('active');
    });
  }

  TaskOverview.prototype.setMainView = function(mainView) {
    var _this = this;

    this.mainView = mainView;
    return KD.utils.defer(function() {
      return _this.lectureListController.itemsOrdered[0].setClass('active');
    });
  };

  TaskOverview.prototype.pistachio = function() {
    return "{{> this.lectureList}}";
  };

  return TaskOverview;

})(JView);


/* BLOCK ENDS */



/* BLOCK STARTS /Source: /Users/arvidkahl/Applications/kodelectures.kdapp/app/views.coffee */

var Ace, AppCreator, HelpView, LiveViewer, Settings, TaskView, _ref,
  _this = this,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Settings = KodeLectures.Settings, Ace = KodeLectures.Ace;

_ref = KodeLectures.Core, LiveViewer = _ref.LiveViewer, AppCreator = _ref.AppCreator, HelpView = _ref.HelpView, TaskView = _ref.TaskView;

require(["https://raw.github.com/chjj/marked/master/lib/marked.js"], function(marked) {
  var options, _ref1, _ref2, _ref3, _ref4, _ref5;

  options = {};
  if ((_ref1 = options.gfm) == null) {
    options.gfm = true;
  }
  if ((_ref2 = options.sanitize) == null) {
    options.sanitize = true;
  }
  if ((_ref3 = options.highlight) == null) {
    options.highlight = function(code, lang) {
      var e, _e;

      try {
        return hljs.highlight(lang, code).value;
      } catch (_error) {
        e = _error;
        try {
          return hljs.highlightAuto(code).value;
        } catch (_error) {
          _e = _error;
          return code;
        }
      }
    };
  }
  if ((_ref4 = options.breaks) == null) {
    options.breaks = true;
  }
  if ((_ref5 = options.langPrefix) == null) {
    options.langPrefix = 'lang-';
  }
  return marked.setOptions(options);
});

KodeLectures.Views.Editor = (function() {
  function Editor(options) {
    this.view = new KDView({
      tagName: "textarea"
    });
    this.view.domElement.css({
      "font-family": "monospace"
    });
    if (options.defaultValue) {
      this.setValue(options.defaultValue);
    }
    if (options.callback) {
      this.view.domElement.keyup(options.callback);
    }
  }

  Editor.prototype.setValue = function(value) {
    return this.view.domElement.html(value);
  };

  Editor.prototype.getValue = function() {
    return this.view.domElement.val();
  };

  Editor.prototype.getView = function() {
    return this.view;
  };

  Editor.prototype.getElement = function() {
    return this.view.domElement.get(0);
  };

  return Editor;

})();

KodeLectures.Views.MainView = (function(_super) {
  var Editor, TaskOverview, _ref1;

  __extends(MainView, _super);

  _ref1 = KodeLectures.Views, Editor = _ref1.Editor, HelpView = _ref1.HelpView, TaskView = _ref1.TaskView, TaskOverview = _ref1.TaskOverview;

  function MainView() {
    MainView.__super__.constructor.apply(this, arguments);
    this.liveViewer = LiveViewer.getSingleton();
    this.listenWindowResize();
    this.autoScroll = true;
    this.currentLecture = 0;
    this.lastSelectedCourse = 0;
  }

  MainView.prototype.delegateElements = function() {
    var item, key, nextButton, overflowFix, previousButton, runButton,
      _this = this;

    this.splitViewWrapper = new KDView;
    overflowFix = function() {
      var height;

      height = ($(".kdview.marKDown")).height() - 39;
      return ($(".kodepad-editors")).height(height);
    };
    ($(window)).on("resize", overflowFix);
    this.preview = new KDView({
      cssClass: "preview-pane"
    });
    this.liveViewer.setPreviewView(this.preview);
    this.editor = new Editor({
      defaultValue: Settings.lectures[this.lastSelectedCourse].lectures[0].code,
      callback: function() {}
    });
    this.editor.getView().hide();
    this.taskView = new TaskView({}, KodeLectures.Settings.lectures[this.lastSelectedCourse || 0].lectures[0]);
    this.taskOverview = new TaskOverview({}, KodeLectures.Settings.lectures[this.lastSelectedCourse || 0].lectures);
    this.aceView = new KDView({
      cssClass: 'editor code-editor'
    });
    this.aceWrapperView = new KDView({
      cssClass: 'ace-wrapper-view'
    });
    this.aceWrapperView.addSubView(this.aceView);
    this.mdHelpView = new HelpView({
      cssClass: 'md-help-view'
    });
    this.editorSplitView = new KDSplitView({
      type: "horizontal",
      resizable: true,
      sizes: ["62%", "38%"],
      views: [this.aceWrapperView, this.preview]
    });
    this.taskSplitViewWrapper = new KDView;
    this.taskSplitView = new KDSplitView({
      type: 'vertical',
      resizable: false,
      cssClass: 'task-splitview',
      sizes: ['62%', '38%'],
      views: [this.taskView, this.taskOverview]
    });
    this.splitView = new KDSplitView({
      cssClass: "kodepad-editors",
      type: "vertical",
      resizable: true,
      sizes: ["50%", "50%"],
      views: [this.editorSplitView, this.taskSplitView]
    });
    this.splitViewWrapper.addSubView(this.splitView);
    this.buildAce();
    this.splitView.on('ResizeDidStop', function() {
      var _ref2;

      return (_ref2 = _this.ace) != null ? _ref2.resize() : void 0;
    });
    this.controlButtons = new KDView({
      cssClass: 'header-buttons'
    });
    this.controlView = new KDView({
      cssClass: 'control-pane editor-header'
    });
    runButton = new KDButtonView({
      cssClass: "cupid-green control-button run",
      title: 'Run this code',
      tooltip: {
        title: 'Run your code'
      },
      callback: function(event) {
        _this.liveViewer.active = true;
        return _this.liveViewer.previewCode(_this.editor.getValue());
      }
    });
    this.controlButtons.addSubView(nextButton = new KDButtonView({
      cssClass: "clean-gray editor-button control-button next",
      title: 'Next lecture',
      tooltip: {
        title: 'Go to the next lecture'
      },
      callback: function(event) {
        return _this.emit('NextLectureRequested');
      }
    }));
    this.controlButtons.addSubView(previousButton = new KDButtonView({
      cssClass: "clean-gray editor-button control-button previous",
      title: 'Previous lecture',
      tooltip: {
        title: 'Go to the previous lecture'
      },
      callback: function(event) {
        return _this.emit('PreviousLectureRequested');
      }
    }));
    this.on('NextLectureRequested', function() {
      if (_this.currentLecture !== KodeLectures.Settings.lectures[_this.lastSelectedCourse || 0].lectures.length - 1) {
        previousButton.unsetClass('disabled');
        _this.exampleCode.setValue(++_this.currentLecture);
        return _this.exampleCode.getOptions().callback();
      } else {
        return nextButton.setClass('disabled');
      }
    });
    this.on('PreviousLectureRequested', function() {
      if (_this.currentLecture !== 0) {
        nextButton.unsetClass('disabled');
        _this.exampleCode.setValue(--_this.currentLecture);
        return _this.exampleCode.getOptions().callback();
      } else {
        return previousButton.setClass('disabled');
      }
    });
    this.courseSelect = new KDSelectBox({
      label: new KDLabelView({
        title: 'Course: '
      }),
      defaultValue: this.lastSelectedCourse || "0",
      cssClass: 'control-button code-examples',
      selectOptions: (function() {
        var _i, _len, _ref2, _results;

        _ref2 = KodeLectures.Settings.lectures;
        _results = [];
        for (key = _i = 0, _len = _ref2.length; _i < _len; key = ++_i) {
          item = _ref2[key];
          _results.push({
            title: item.title,
            value: key
          });
        }
        return _results;
      })(),
      callback: function() {
        _this.lastSelectedCourse = _this.courseSelect.getValue();
        _this.exampleCode.setSelectOptions((function() {
          var _i, _len, _ref2, _results;

          _ref2 = KodeLectures.Settings.lectures[this.lastSelectedCourse || 0].lectures;
          _results = [];
          for (key = _i = 0, _len = _ref2.length; _i < _len; key = ++_i) {
            item = _ref2[key];
            _results.push({
              title: item.title,
              value: key
            });
          }
          return _results;
        }).call(_this));
        _this.exampleCode.setValue(0);
        return _this.emit('LectureChanged');
      }
    });
    this.exampleCode = new KDSelectBox({
      label: new KDLabelView({
        title: 'Lecture: '
      }),
      defaultValue: this.lastSelectedItem || "0",
      cssClass: 'control-button code-examples',
      selectOptions: (function() {
        var _i, _len, _ref2, _results;

        _ref2 = KodeLectures.Settings.lectures[this.lastSelectedCourse || 0].lectures;
        _results = [];
        for (key = _i = 0, _len = _ref2.length; _i < _len; key = ++_i) {
          item = _ref2[key];
          _results.push({
            title: item.title,
            value: key
          });
        }
        return _results;
      }).call(this),
      callback: function() {
        return _this.emit('LectureChanged');
      }
    });
    this.on('LectureChanged', function() {
      var code, language, _ref2;

      _this.lastSelectedItem = _this.exampleCode.getValue();
      _ref2 = KodeLectures.Settings.lectures[_this.lastSelectedCourse].lectures[_this.lastSelectedItem], code = _ref2.code, language = _ref2.language;
      _this.ace.getSession().setValue(code);
      _this.taskView.emit('LectureChanged', KodeLectures.Settings.lectures[_this.lastSelectedCourse].lectures[_this.lastSelectedItem]);
      console.log('emitting');
      _this.taskOverview.emit('LectureChanged', {
        course: KodeLectures.Settings.lectures[_this.lastSelectedCourse],
        index: _this.lastSelectedItem
      });
      _this.ace.getSession().setMode("ace/mode/" + language);
      _this.currentLang = language;
      _this.languageSelect.setValue(language);
      return _this.currentLecture = _this.lastSelectedItem;
    });
    this.languageSelect = new KDSelectBox({
      label: new KDLabelView({
        title: 'Language: '
      }),
      selectOptions: [
        {
          value: 'javascript',
          title: 'JavaScript'
        }, {
          value: 'coffee',
          title: 'CoffeeScript'
        }, {
          value: 'ruby',
          title: 'Ruby'
        }, {
          value: 'python',
          title: 'Python'
        }
      ],
      title: 'Language Selection',
      defaultValue: 'javascript',
      cssClass: 'control-button language',
      callback: function(item) {
        _this.currentLang = item;
        return _this.ace.getSession().setMode("ace/mode/" + item);
      }
    });
    this.currentLang = KodeLectures.Settings.lectures[this.lastSelectedCourse || 0].lectures[0].language;
    this.controlView.addSubView(this.languageSelect.options.label);
    this.controlView.addSubView(this.languageSelect);
    this.controlView.addSubView(this.courseSelect.options.label);
    this.controlView.addSubView(this.courseSelect);
    this.controlView.addSubView(this.exampleCode.options.label);
    this.controlView.addSubView(this.exampleCode);
    this.aceWrapperView.addSubView(runButton);
    this.controlView.addSubView(this.controlButtons);
    this.liveViewer.setSplitView(this.splitView);
    this.liveViewer.setMainView(this);
    this.taskView.setMainView(this);
    this.taskOverview.setMainView(this);
    this.liveViewer.previewCode(this.editor.getValue());
    this.utils.defer(function() {
      return ($(window)).resize();
    });
    this.utils.wait(50, function() {
      var _ref2;

      ($(window)).resize();
      return (_ref2 = _this.ace) != null ? _ref2.resize() : void 0;
    });
    return this.utils.wait(1000, function() {
      return _this.ace.renderer.scrollBar.on('scroll', function() {
        if (_this.autoScroll === true) {
          return _this.setPreviewScrollPercentage(_this.getEditScrollPercentage());
        }
      });
    });
  };

  MainView.prototype.getEditScrollPercentage = function() {};

  MainView.prototype.setPreviewScrollPercentage = function(percentage) {};

  MainView.prototype.pistachio = function() {
    return "{{> this.controlView}}\n{{> this.editor.getView()}}\n{{> this.splitViewWrapper}}";
  };

  MainView.prototype.buildAce = function() {
    var ace, update,
      _this = this;

    ace = this.getOptions().ace;
    try {
      update = KD.utils.throttle(function() {
        _this.editor.setValue(_this.ace.getSession().getValue());
        return _this.editor.getView().domElement.trigger("keyup");
      }, Settings.aceThrottle);
      this.ace = ace.edit(this.aceView.domElement.get(0));
      this.ace.setTheme(Settings.theme);
      this.ace.getSession().setMode("ace/mode/javascript");
      this.ace.getSession().setTabSize(2);
      this.ace.getSession().setUseSoftTabs(true);
      this.ace.getSession().setValue(this.editor.getValue());
      this.ace.getSession().on("change", function() {
        return update();
      });
      this.editor.setValue(this.ace.getSession().getValue());
      return this.ace.commands.addCommand({
        name: 'save',
        bindKey: {
          win: 'Ctrl-S',
          mac: 'Command-S'
        },
        exec: function() {
          return _this.editor.setValue(_this.ace.getSession().getValue());
        }
      });
    } catch (_error) {}
  };

  MainView.prototype.viewAppended = function() {
    this.delegateElements();
    this.setTemplate(this.pistachio());
    return this.buildAce();
  };

  return MainView;

})(JView);


/* BLOCK ENDS */



/* BLOCK STARTS /Source: /Users/arvidkahl/Applications/kodelectures.kdapp/index.coffee */

var MainView;

MainView = KodeLectures.Views.MainView;

(function() {
  var loader, mainView, markdownModal,
    _this = this;

  KD.enableLogs();
  console.log('Development version of KodeLectures starting...');
  loader = new KDView({
    cssClass: "KodeLectures loading",
    partial: "Loading KodeLectures..."
  });
  mainView = {};
  markdownModal = new KDModalView({
    width: window.innerWidth - 100,
    height: window.innerHeight - 100,
    overlay: false,
    title: 'KodeLectures',
    buttons: {
      Yes: {
        loader: {
          color: "#ffffff",
          diameter: 16
        },
        style: "modal-clean-gray",
        callback: function() {
          var value;

          new KDNotificationView({
            title: "Clicked yes!"
          });
          value = mainView.ace.getSession().getValue();
          console.log(value);
          markdownModal.destroy();
          return value;
        }
      },
      No: {
        loader: {
          color: "#ffffff",
          diameter: 16
        },
        style: "modal-clean-gray",
        callback: function() {
          var value;

          new KDNotificationView({
            title: "Clicked no!"
          });
          value = mainView.ace.getSession().getValue();
          console.log(value);
          markdownModal.destroy();
          return value;
        }
      }
    }
  });
  markdownModal.addSubView(loader);
  return require(["ace/ace"], function(Ace) {
    mainView = new MainView({
      cssClass: "marKDown",
      ace: Ace
    });
    markdownModal.removeSubView(loader);
    markdownModal.addSubView(mainView);
    return markdownModal.$('.kdmodal-content').height(window.innerHeight - 95);
  });
})();


/* BLOCK ENDS */

/* KDAPP ENDS */

}).call();