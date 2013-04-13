// Compiled by Koding Servers at Fri Apr 12 2013 22:02:49 GMT-0700 (PDT) in server time

(function() {

/* KDAPP STARTS */

/* BLOCK STARTS /Source: /Users/arvidkahl/Applications/kodelectures.kdapp/app/settings.coffee */

var KodeLectures;

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
  },
  Controllers: {
    FileIOController: null
  }
};

KodeLectures.Settings.lectures = [];


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

  LiveViewer.prototype.previewCode = function(code, execute) {
    var command, course, courses, ioController, kiteController, lecture, _ref,
      _this = this;

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
      _ref = this.mainView, ioController = _ref.ioController, courses = _ref.courses, course = _ref.lastSelectedCourse, lecture = _ref.lastSelectedItem;
      return ioController.runFile(courses, course, lecture, execute, function(err, res) {
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
    var codeHint, codeHintText, embedType, taskText, videoUrl, _ref,
      _this = this;

    TaskView.__super__.constructor.apply(this, arguments);
    this.setClass('task-view');
    console.log('taskview');
    _ref = this.getData(), videoUrl = _ref.videoUrl, codeHintText = _ref.codeHintText, codeHint = _ref.codeHint, embedType = _ref.embedType, taskText = _ref.taskText;
    if (codeHint == null) {
      codeHint = '';
    }
    if (codeHintText == null) {
      codeHintText = '';
    }
    if (taskText == null) {
      taskText = '';
    }
    this.embed = new KDView({
      cssClass: 'embed',
      partial: videoUrl && embedType === 'youtube' ? "<iframe src=\"" + videoUrl + "\" frameborder=\"0\" allowfullscreen></iframe>" : ''
    });
    if (!videoUrl) {
      this.embed.hide();
    }
    this.nextLectureButton = new KDButtonView({
      title: 'Next Lecture',
      cssClass: 'cupid-green hidden fr task-next-button',
      callback: function() {
        return _this.mainView.emit('NextLectureRequested');
      }
    });
    this.taskTextView = new KDView({
      cssClass: 'task-text-view has-markdown',
      partial: "<span class='text'>Assignment</span><span class='data'>" + (marked(taskText)) + "</span>"
    });
    this.resultView = new KDView({
      cssClass: 'result-view hidden'
    });
    this.hintView = new KDView({
      cssClass: 'hint-view has-markdown',
      partial: '<span class="text">Show hint</span>',
      click: function() {
        return _this.hintView.updatePartial("<span class='text'>Hint</span><span class='data'>" + (marked(codeHintText)) + "</span>");
      }
    });
    this.hintCodeView = new KDView({
      cssClass: 'hint-code-view has-markdown',
      partial: '<span class="text">Show solution</span>',
      click: function() {
        return _this.hintCodeView.updatePartial("<span class='text'>Solution</span><span class='data'>" + (marked(codeHint)) + "</span>");
      }
    });
    this.on('LectureChanged', function(lecture) {
      var _ref1;

      _this.setData(lecture);
      _this.resultView.hide();
      _this.nextLectureButton.hide();
      _this.mainView.liveViewer.active = false;
      if ((_ref1 = _this.mainView.liveViewer.mdPreview) != null) {
        _ref1.updatePartial('<div class="info"><pre>When you run your code, you will see the results here</pre></div>');
      }
      _this.taskTextView.updatePartial("<span class='text'>Assignment</span><span class='data'>" + (marked(_this.getData().taskText)) + "</span>");
      _this.hintView.updatePartial('<span class="text">Show hint</span>');
      _this.hintCodeView.updatePartial('<span class="text">Show solution</span>');
      videoUrl = lecture.videoUrl;
      if (videoUrl) {
        _this.embed.show();
        _this.embed.updatePartial("<iframe src=\"" + videoUrl + "\" frameborder=\"0\" allowfullscreen></iframe>");
      } else {
        _this.embed.hide();
      }
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
    return "{{> this.nextLectureButton}}\n{{> this.resultView}}    \n\n{{> this.embed}}\n{{> this.taskTextView}}\n\n{{> this.hintView}}\n{{> this.hintCodeView}}";
  };

  return TaskView;

})(JView);

KodeLectures.Views.TaskOverviewListItemView = (function(_super) {
  __extends(TaskOverviewListItemView, _super);

  function TaskOverviewListItemView() {
    var summary, title, _ref;

    TaskOverviewListItemView.__super__.constructor.apply(this, arguments);
    console.log('taskoverviewlistitem');
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
    console.log('taskoverview');
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

KodeLectures.Views.CourseLectureListItemView = (function(_super) {
  __extends(CourseLectureListItemView, _super);

  function CourseLectureListItemView() {
    CourseLectureListItemView.__super__.constructor.apply(this, arguments);
    console.log('courselecturelistitemview');
    log(this.getData());
    this.lectureTitle = new KDView({
      cssClass: 'lecture-listitem',
      partial: this.getData().title
    });
  }

  CourseLectureListItemView.prototype.viewAppended = function() {
    this.setTemplate(this.pistachio());
    return this.template.update();
  };

  CourseLectureListItemView.prototype.pistachio = function() {
    return "{{> this.lectureTitle}}";
  };

  CourseLectureListItemView.prototype.click = function() {
    return this.getDelegate().emit('LectureSelected', this.getData());
  };

  return CourseLectureListItemView;

})(KDListItemView);

KodeLectures.Views.CourseSelectionItemView = (function(_super) {
  var CourseLectureListItemView;

  __extends(CourseSelectionItemView, _super);

  CourseLectureListItemView = KodeLectures.Views.CourseLectureListItemView;

  function CourseSelectionItemView() {
    var lectureCount;

    CourseSelectionItemView.__super__.constructor.apply(this, arguments);
    console.log('courseselectionitemview');
    this.setClass('selection-listitem');
    lectureCount = this.getData().lectures.length;
    this.titleText = new KDView({
      partial: "<span>" + (this.getData().title) + "</span><span class='lectures'>" + lectureCount + " lecture" + (lectureCount === 1 ? '' : 's') + "</span>",
      cssClass: 'title'
    });
    this.descriptionText = new KDView({
      partial: this.getData().description,
      cssClass: 'description'
    });
    this.lectureController = new KDListViewController({
      itemClass: CourseLectureListItemView,
      delegate: this
    }, {
      items: this.getData().lectures
    });
    this.lectureList = this.lectureController.getView();
  }

  CourseSelectionItemView.prototype.viewAppended = function() {
    this.setTemplate(this.pistachio());
    return this.template.update();
  };

  CourseSelectionItemView.prototype.click = function() {
    return this.getDelegate().emit('CourseSelected', this.getData());
  };

  CourseSelectionItemView.prototype.pistachio = function() {
    return "{{> this.titleText}}\n{{> this.descriptionText}}\n{{> this.lectureList}}";
  };

  return CourseSelectionItemView;

})(KDListItemView);

KodeLectures.Views.CourseSelectionView = (function(_super) {
  var CourseSelectionItemView;

  __extends(CourseSelectionView, _super);

  CourseSelectionItemView = KodeLectures.Views.CourseSelectionItemView;

  function CourseSelectionView() {
    var courses,
      _this = this;

    CourseSelectionView.__super__.constructor.apply(this, arguments);
    console.log('courseselectionview');
    courses = this.getData();
    this.courseController = new KDListViewController({
      itemClass: CourseSelectionItemView,
      delegate: this
    }, {
      items: courses
    });
    this.courseView = this.courseController.getView();
    this.on('NewCourseImported', function(course) {
      _this.courseController.addItem(course);
      return courses.push(course);
    });
    this.courseController.listView.on('CourseSelected', function(course) {
      return _this.mainView.emit('CourseChanged', courses.indexOf(course));
    });
    this.courseHeader = new KDView({
      cssClass: 'course-header',
      partial: '<h1>Select a  course:</h1>'
    });
  }

  CourseSelectionView.prototype.setMainView = function(mainView) {
    this.mainView = mainView;
  };

  CourseSelectionView.prototype.pistachio = function() {
    return "{{> this.courseHeader}}\n{{> this.courseView}}";
  };

  return CourseSelectionView;

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
  var CourseSelectionView, Editor, TaskOverview, _ref1;

  __extends(MainView, _super);

  _ref1 = KodeLectures.Views, Editor = _ref1.Editor, HelpView = _ref1.HelpView, TaskView = _ref1.TaskView, TaskOverview = _ref1.TaskOverview, CourseSelectionView = _ref1.CourseSelectionView;

  function MainView() {
    var _this = this;

    MainView.__super__.constructor.apply(this, arguments);
    this.liveViewer = LiveViewer.getSingleton();
    this.listenWindowResize();
    this.autoScroll = true;
    this.currentLecture = 0;
    this.lastSelectedCourse = 0;
    this.ioController = new KodeLectures.Controllers.FileIOController;
    this.ioController.emit('CourseImportRequested');
    this.ioController.on('NewCourseImported', function(course) {
      console.log('Forwarding new Course to view');
      _this.selectionView.emit('NewCourseImported', course);
      return _this.courses.push(course);
    });
    this.courses = [];
  }

  MainView.prototype.delegateElements = function() {
    var item, key, nextButton, overflowFix, previousButton, runButton, _ref10, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9,
      _this = this;

    this.splitViewWrapper = new KDView;
    overflowFix = function() {
      var height;

      height = ($(".kdview.marKDown")).height() - 39;
      return ($(".kodepad-editors")).height(height);
    };
    ($(window)).on("resize", overflowFix);
    (function() {
      var lastAceHeight, lastAceWidth;

      lastAceHeight = 0;
      lastAceWidth = 0;
      return setInterval(function() {
        var aceHeight, aceWidth;

        aceHeight = _this.aceView.getHeight();
        aceWidth = _this.aceView.getWidth();
        if (aceHeight !== lastAceHeight || aceWidth !== lastAceWidth) {
          _this.ace.resize();
          lastAceHeight = _this.aceView.getHeight();
          return lastAceWidth = _this.aceView.getWidth();
        }
      }, 20);
    })();
    this.preview = new KDView({
      cssClass: "preview-pane"
    });
    this.liveViewer.setPreviewView(this.preview);
    this.editor = new Editor({
      defaultValue: ((_ref2 = Settings.lectures[this.lastSelectedCourse]) != null ? (_ref3 = _ref2.lectures) != null ? (_ref4 = _ref3[0]) != null ? _ref4.code : void 0 : void 0 : void 0) || '',
      callback: function() {}
    });
    this.editor.getView().hide();
    this.taskView = new TaskView({}, ((_ref5 = this.courses[this.lastSelectedCourse || 0]) != null ? (_ref6 = _ref5.lectures) != null ? _ref6[0] : void 0 : void 0) || {});
    this.taskOverview = new TaskOverview({}, ((_ref7 = this.courses[this.lastSelectedCourse || 0]) != null ? _ref7.lectures : void 0) || []);
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
      cssClass: "kodepad-editors out",
      type: "vertical",
      resizable: true,
      sizes: ["50%", "50%"],
      views: [this.editorSplitView, this.taskSplitView]
    });
    this.splitViewWrapper.addSubView(this.splitView);
    this.splitViewWrapper.addSubView(this.selectionView = new CourseSelectionView({
      cssClass: 'selection-view in'
    }, Settings.lectures));
    this.buildAce();
    this.splitView.on('ResizeDidStop', function() {
      var _ref8;

      return (_ref8 = _this.ace) != null ? _ref8.resize() : void 0;
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
        return _this.liveViewer.previewCode(_this.editor.getValue(), _this.courses[_this.lastSelectedCourse].lectures[_this.lastSelectedItem].execute);
      }
    });
    this.controlButtons.addSubView(nextButton = new KDButtonView({
      cssClass: "clean-gray editor-button control-button next hidden",
      title: 'Courses',
      tooltip: {
        title: 'Go to the course list'
      },
      callback: function(event) {
        return _this.emit('CourseRequested');
      }
    }));
    this.controlButtons.addSubView(previousButton = new KDButtonView({
      cssClass: "clean-gray editor-button control-button previous",
      title: 'Lecture',
      tooltip: {
        title: 'Go to the current lecture'
      },
      callback: function(event) {
        return _this.emit('LectureRequested');
      }
    }));
    this.on('CourseRequested', function() {
      _this.splitView.setClass('out');
      _this.selectionView.setClass('in');
      previousButton.show();
      return nextButton.hide();
    });
    this.on('LectureRequested', function() {
      _this.splitView.unsetClass('out');
      _this.selectionView.unsetClass('in');
      nextButton.show();
      return previousButton.hide();
    });
    this.on('NextLectureRequested', function() {
      var _ref8, _ref9;

      if (_this.currentLecture !== ((_ref8 = _this.courses[_this.lastSelectedCourse || 0]) != null ? (_ref9 = _ref8.lectures) != null ? _ref9.length : void 0 : void 0) - 1) {
        _this.exampleCode.setValue(++_this.currentLecture);
        return _this.exampleCode.getOptions().callback();
      }
    });
    this.on('PreviousLectureRequested', function() {
      if (_this.currentLecture !== 0) {
        _this.exampleCode.setValue(--_this.currentLecture);
        return _this.exampleCode.getOptions().callback();
      }
    });
    this.courseSelect = new KDSelectBox({
      label: new KDLabelView({
        title: 'Course: '
      }),
      defaultValue: this.lastSelectedCourse || "0",
      cssClass: 'control-button code-examples',
      selectOptions: (function() {
        var _i, _len, _ref8, _results;

        _ref8 = this.courses;
        _results = [];
        for (key = _i = 0, _len = _ref8.length; _i < _len; key = ++_i) {
          item = _ref8[key];
          _results.push({
            title: item.title,
            value: key
          });
        }
        return _results;
      }).call(this),
      callback: function() {
        return _this.emit('CourseChanged', _this.courseSelect.getValue());
      }
    });
    this.exampleCode = new KDSelectBox({
      label: new KDLabelView({
        title: 'Lecture: '
      }),
      defaultValue: this.lastSelectedItem || "0",
      cssClass: 'control-button code-examples',
      selectOptions: (function() {
        var _i, _len, _ref8, _ref9, _results;

        _ref9 = ((_ref8 = this.courses[this.lastSelectedCourse || 0]) != null ? _ref8.lectures : void 0) || [];
        _results = [];
        for (key = _i = 0, _len = _ref9.length; _i < _len; key = ++_i) {
          item = _ref9[key];
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
    this.on('CourseChanged', function(course) {
      if (course) {
        _this.courseSelect.setValue(course);
      }
      _this.lastSelectedCourse = course;
      _this.exampleCode._$select.find("option").remove();
      _this.exampleCode.setSelectOptions((function() {
        var _i, _len, _ref8, _ref9, _results;

        _ref9 = ((_ref8 = this.courses[this.lastSelectedCourse || 0]) != null ? _ref8.lectures : void 0) || [];
        _results = [];
        for (key = _i = 0, _len = _ref9.length; _i < _len; key = ++_i) {
          item = _ref9[key];
          _results.push({
            title: item.title,
            value: key
          });
        }
        return _results;
      }).call(_this));
      _this.exampleCode.setValue(0);
      _this.emit('LectureChanged');
      return _this.emit('LectureRequested');
    });
    this.on('LectureChanged', function() {
      var code, codeFile, language, _ref8;

      _this.lastSelectedItem = _this.exampleCode.getValue();
      _ref8 = _this.courses[_this.lastSelectedCourse].lectures[_this.lastSelectedItem], code = _ref8.code, codeFile = _ref8.codeFile, language = _ref8.language;
      _this.ioController.readFile(_this.courses, _this.lastSelectedCourse, _this.lastSelectedItem, "codeFile", function(err, contents) {
        if (!err) {
          console.log(contents);
          return _this.ace.getSession().setValue(contents);
        } else {
          return console.log(err);
        }
      });
      _this.taskView.emit('LectureChanged', _this.courses[_this.lastSelectedCourse].lectures[_this.lastSelectedItem]);
      console.log('emitting');
      _this.taskOverview.emit('LectureChanged', {
        course: _this.courses[_this.lastSelectedCourse],
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
    this.currentLang = ((_ref8 = this.courses[this.lastSelectedCourse || 0]) != null ? (_ref9 = _ref8.lectures) != null ? (_ref10 = _ref9[0]) != null ? _ref10.language : void 0 : void 0 : void 0) || 'javascript';
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
    this.selectionView.setMainView(this);
    this.utils.defer(function() {
      return ($(window)).resize();
    });
    this.utils.wait(50, function() {
      var _ref11;

      ($(window)).resize();
      return (_ref11 = _this.ace) != null ? _ref11.resize() : void 0;
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
        exec: function(event) {
          console.log(event);
          _this.editor.setValue(_this.ace.getSession().getValue());
          return _this.ioController.saveFile(_this.courses, _this.lastSelectedCourse, _this.lastSelectedItem, _this.ace.getSession().getValue());
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



/* BLOCK STARTS /Source: /Users/arvidkahl/Applications/kodelectures.kdapp/app/io.coffee */

var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

KodeLectures.Controllers.FileIOController = (function(_super) {
  __extends(FileIOController, _super);

  function FileIOController() {
    FileIOController.__super__.constructor.apply(this, arguments);
    this.kiteController = KD.getSingleton("kiteController");
    this.nickname = KD.whoami().profile.nickname;
    this.name = 'kodelectures';
    this.appPath = "/Users/" + this.nickname + "/Applications";
    this.basePath = "" + this.appPath + "/" + this.name + ".kdapp";
    this.attachListeners();
  }

  FileIOController.prototype.readFile = function(courses, course, lecture, key, callback) {
    var codeFileInstance, currentFile;

    currentFile = "" + this.basePath + "/courses/" + courses[course].path + "/" + courses[course].lectures[lecture][key];
    codeFileInstance = FSHelper.createFileFromPath(currentFile);
    return codeFileInstance.fetchContents(callback);
  };

  FileIOController.prototype.saveFile = function(courses, course, lecture, value, callback) {
    var codeFileInstance, currentFile;

    if (callback == null) {
      callback = function() {};
    }
    currentFile = "" + this.basePath + "/courses/" + courses[course].path + "/" + courses[course].lectures[lecture].codeFile;
    codeFileInstance = FSHelper.createFileFromPath(currentFile);
    return codeFileInstance.save(value, callback);
  };

  FileIOController.prototype.runFile = function(courses, course, lecture, execute, callback) {
    return this.kiteController.run("cd " + this.basePath + "/courses/" + courses[course].path + ";" + execute, callback);
  };

  FileIOController.prototype.attachListeners = function() {
    var coursePath, path, root,
      _this = this;

    this.name = this.name.replace(/.kdapp$/, '');
    root = "/Users/" + this.nickname + "/Applications";
    path = "" + root + "/" + this.name + ".kdapp";
    coursePath = "" + path + "/courses";
    return this.on('CourseImportRequested', function() {
      var command;

      command = "ls " + coursePath;
      return _this.kiteController.run(command, function(err, res) {
        var course, courses, _i, _len, _results;

        if (!err) {
          courses = res.trim().split("\n");
          _results = [];
          for (_i = 0, _len = courses.length; _i < _len; _i++) {
            course = courses[_i];
            _results.push(_this.kiteController.run("cat " + coursePath + "/" + course + "/manifest.json", function(err, manifest) {
              var e, newCourse;

              try {
                newCourse = JSON.parse(manifest);
                return _this.emit('NewCourseImported', newCourse);
              } catch (_error) {
                e = _error;
                return console.log(e);
              }
            }));
          }
          return _results;
        }
      });
    });
  };

  return FileIOController;

})(KDController);


/* BLOCK ENDS */



/* BLOCK STARTS /Source: /Users/arvidkahl/Applications/kodelectures.kdapp/index.coffee */

var MainView, loader,
  _this = this;

MainView = KodeLectures.Views.MainView;

KD.enableLogs();

console.log('Development version of KodeLectures starting...');

loader = new KDView({
  cssClass: "KodeLectures loading",
  partial: "Loading KodeLectures..."
});

appView.addSubView(loader);

require(["ace/ace"], function(Ace) {
  var mainView;

  mainView = new MainView({
    cssClass: "marKDown",
    ace: Ace
  });
  appView.removeSubView(loader);
  return appView.addSubView(mainView);
});


/* BLOCK ENDS */

/* KDAPP ENDS */

}).call();