// Compiled by Koding Servers at Sun Apr 14 2013 22:33:56 GMT-0700 (PDT) in server time

(function() {

/* KDAPP STARTS */

/* BLOCK STARTS /Source: /Users/arvidkahl/Applications/KodeLectures.kdapp/app/settings.coffee */

var KodeLectures;

KodeLectures = {
  Settings: {
    theme: "ace/theme/monokai",
    exampleCode: null,
    aceThrottle: 400
  },
  Core: {
    Utils: null,
    LiveViewer: null
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



/* BLOCK STARTS /Source: /Users/arvidkahl/Applications/KodeLectures.kdapp/app/core.coffee */

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

  return LiveViewer;

}).call(this);

KodeLectures.Views.TaskSubItemView = (function(_super) {
  __extends(TaskSubItemView, _super);

  function TaskSubItemView() {
    var cssClass,
      _this = this;

    TaskSubItemView.__super__.constructor.apply(this, arguments);
    cssClass = this.getData().cssClass;
    this.setClass(cssClass);
    this.header = new KDCustomHTMLView({
      tagName: 'span',
      cssClass: 'text',
      click: function() {
        return _this.content.show();
      }
    });
    this.content = new KDCustomHTMLView({
      tagName: 'span',
      cssClass: 'data'
    });
    this.updateViews(this.getData());
  }

  TaskSubItemView.prototype.updateViews = function(data) {
    var content, contentHidden, contentPartial, headerHidden, initialContent, initialContentHidden, initialHeaderHidden, initialTitle, title, type, _ref;

    title = data.title, content = data.content, headerHidden = data.headerHidden, contentHidden = data.contentHidden;
    _ref = this.getData(), type = _ref.type, initialTitle = _ref.title, initialContent = _ref.content, initialContentHidden = _ref.contentHidden, initialHeaderHidden = _ref.headerHidden;
    this.header.updatePartial(title || initialTitle);
    contentPartial = (function() {
      switch (type) {
        case 'lectureText':
        case 'taskText':
        case 'codeHint':
        case 'codeHintText':
          return marked(content || initialContent);
        case 'embed':
          if (content.type === 'youtube') {
            return "<iframe src=\"" + content.url + "\" frameborder=\"0\" allowfullscreen></iframe>";
          }
      }
    })();
    this.content.updatePartial(contentPartial);
    if (headerHidden == null) {
      headerHidden = initialHeaderHidden;
    }
    if (contentHidden == null) {
      contentHidden = initialContentHidden;
    }
    if (headerHidden) {
      this.header.hide();
    } else {
      this.header.show();
    }
    if (contentHidden) {
      this.content.hide();
    } else {
      this.content.show();
    }
    if (!(type !== 'embed' && content && content !== '' || type === 'embed' && ((content != null ? content.url : void 0) != null))) {
      return this.hide();
    } else {
      return this.show();
    }
  };

  TaskSubItemView.prototype.viewAppended = function() {
    this.setTemplate(this.pistachio());
    return this.template.update();
  };

  TaskSubItemView.prototype.pistachio = function() {
    return "{{> this.header}}\n{{> this.content}}";
  };

  return TaskSubItemView;

})(KDListItemView);

KodeLectures.Views.TaskView = (function(_super) {
  var TaskSubItemView;

  __extends(TaskView, _super);

  TaskSubItemView = KodeLectures.Views.TaskSubItemView;

  TaskView.prototype.setMainView = function(mainView) {
    this.mainView = mainView;
  };

  function TaskView() {
    var embedType, videoUrl, _ref, _ref1, _ref2, _ref3, _ref4,
      _this = this;

    TaskView.__super__.constructor.apply(this, arguments);
    this.setClass('task-view');
    _ref = this.getData(), videoUrl = _ref.videoUrl, this.codeHintText = _ref.codeHintText, this.codeHint = _ref.codeHint, embedType = _ref.embedType, this.taskText = _ref.taskText, this.lectureText = _ref.lectureText;
    if ((_ref1 = this.codeHint) == null) {
      this.codeHint = '';
    }
    if ((_ref2 = this.codeHintText) == null) {
      this.codeHintText = '';
    }
    if ((_ref3 = this.taskText) == null) {
      this.taskText = '';
    }
    if ((_ref4 = this.lectureText) == null) {
      this.lectureText = '';
    }
    this.subItemController = new KDListViewController({
      itemClass: TaskSubItemView,
      delegate: this
    });
    this.subItemList = this.subItemController.getView();
    this.subItemEmbed = this.subItemController.addItem({
      type: 'embed',
      title: '',
      content: {
        url: videoUrl,
        type: embedType
      },
      cssClass: 'embed',
      contentHidden: false,
      headerHidden: true
    });
    this.subItemLectureText = this.subItemController.addItem({
      type: 'lectureText',
      title: 'Lecture',
      content: this.lectureText,
      cssClass: 'lecture-text-view has-markdown',
      contentHidden: false
    });
    this.subItemTaskText = this.subItemController.addItem({
      type: 'taskText',
      title: 'Assignment',
      content: this.taskText,
      cssClass: 'task-text-view has-markdown',
      contentHidden: false
    });
    this.subItemHintText = this.subItemController.addItem({
      type: 'codeHintText',
      title: 'Hint',
      content: this.codeHintText,
      cssClass: 'hint-view has-markdown',
      contentHidden: true
    });
    this.subItemHintCode = this.subItemController.addItem({
      type: 'codeHint',
      title: 'Solution',
      content: this.codeHint,
      cssClass: 'hint-code-view has-markdown',
      contentHidden: true
    });
    this.nextLectureButton = new KDButtonView({
      title: 'Next Lecture',
      cssClass: 'cupid-green hidden fr task-next-button',
      callback: function() {
        return _this.mainView.emit('NextLectureRequested');
      }
    });
    this.resultView = new KDView({
      cssClass: 'result-view hidden'
    });
    this.on('LectureChanged', function(lecture) {
      var _ref5;

      _this.codeHint = lecture.codeHint, _this.codeHintText = lecture.codeHintText, _this.taskText = lecture.taskText, _this.lectureText = lecture.lectureText, videoUrl = lecture.videoUrl, embedType = lecture.embedType;
      _this.setData(lecture);
      _this.resultView.hide();
      _this.nextLectureButton.hide();
      _this.mainView.liveViewer.active = false;
      if ((_ref5 = _this.mainView.liveViewer.mdPreview) != null) {
        _ref5.updatePartial('<div class="info"><pre>When you run your code, you will see the results here</pre></div>');
      }
      _this.subItemEmbed.updateViews({
        content: {
          url: videoUrl,
          type: embedType
        },
        headerHidden: true
      });
      _this.subItemLectureText.updateViews({
        content: _this.lectureText
      });
      _this.subItemTaskText.updateViews({
        content: _this.taskText
      });
      _this.subItemHintText.updateViews({
        content: _this.codeHintText
      });
      _this.subItemHintCode.updateViews({
        content: _this.codeHint
      });
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
    return "{{> this.nextLectureButton}}\n{{> this.resultView}}    \n{{> this.subItemList}}";
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
    this.mainView = mainView;
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
    var lectureCount,
      _this = this;

    CourseSelectionItemView.__super__.constructor.apply(this, arguments);
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
    this.lectureController.listView.on('LectureSelected', function(data) {
      return _this.getDelegate().emit('LectureSelected', {
        lecture: data,
        course: _this.getData()
      });
    });
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
    this.courseController.listView.on('LectureSelected', function(_arg) {
      var course, lecture;

      course = _arg.course, lecture = _arg.lecture;
      _this.mainView.emit('CourseChanged', courses.indexOf(course));
      return KD.utils.defer(function() {
        return _this.mainView.emit('LectureChanged', course.lectures.indexOf(lecture));
      });
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



/* BLOCK STARTS /Source: /Users/arvidkahl/Applications/KodeLectures.kdapp/app/views.coffee */

var Ace, LiveViewer, Settings, TaskView, _ref,
  _this = this,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Settings = KodeLectures.Settings, Ace = KodeLectures.Ace;

_ref = KodeLectures.Core, LiveViewer = _ref.LiveViewer, TaskView = _ref.TaskView;

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

  _ref1 = KodeLectures.Views, Editor = _ref1.Editor, TaskView = _ref1.TaskView, TaskOverview = _ref1.TaskOverview, CourseSelectionView = _ref1.CourseSelectionView;

  function MainView() {
    var _this = this;

    MainView.__super__.constructor.apply(this, arguments);
    this.liveViewer = LiveViewer.getSingleton();
    this.listenWindowResize();
    this.autoScroll = true;
    this.currentLecture = 0;
    this.currentFile = '';
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
    var overflowFix, runButton, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7,
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
      defaultValue: '',
      callback: function() {}
    });
    this.editor.getView().hide();
    this.taskView = new TaskView({}, ((_ref2 = this.courses[this.lastSelectedCourse || 0]) != null ? (_ref3 = _ref2.lectures) != null ? _ref3[0] : void 0 : void 0) || {});
    this.taskOverview = new TaskOverview({}, ((_ref4 = this.courses[this.lastSelectedCourse || 0]) != null ? _ref4.lectures : void 0) || []);
    this.aceView = new KDView({
      cssClass: 'editor code-editor'
    });
    this.aceWrapperView = new KDView({
      cssClass: 'ace-wrapper-view'
    });
    this.aceWrapperView.addSubView(this.aceView);
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
      sizes: [null, '200px'],
      views: [this.taskView, this.taskOverview]
    });
    this.splitView = new KDSplitView({
      cssClass: "kodepad-editors out",
      type: "vertical",
      resizable: true,
      sizes: ["50%", "50%"],
      views: [this.editorSplitView, this.taskSplitView]
    });
    this.splitView.on('ResizeDidStart', function() {
      return _this.resizeInterval = KD.utils.repeat(100, function() {
        return _this.taskSplitView._windowDidResize({});
      });
    });
    this.splitView.on('ResizeDidStop', function() {
      KD.utils.killRepeat(_this.resizeInterval);
      return _this.taskSplitView._windowDidResize({});
    });
    this.splitViewWrapper.addSubView(this.splitView);
    this.splitViewWrapper.addSubView(this.selectionView = new CourseSelectionView({
      cssClass: 'selection-view in'
    }, Settings.lectures));
    this.buildAce();
    this.splitView.on('ResizeDidStop', function() {
      var _ref5;

      return (_ref5 = _this.ace) != null ? _ref5.resize() : void 0;
    });
    this.controlButtons = new KDView({
      cssClass: 'header-buttons'
    });
    this.controlView = new KDView({
      cssClass: 'control-pane editor-header'
    });
    this.controlButtons.addSubView(this.importButton = new KDButtonView({
      cssClass: "clean-gray editor-button control-button import",
      title: 'Import Course',
      callback: function() {
        var modal;

        return modal = new KDModalViewWithForms({
          title: "Import a Course",
          content: "",
          overlay: true,
          cssClass: "new-kdmodal",
          width: 500,
          height: "auto",
          tabs: {
            navigable: true,
            goToNextFormOnSubmit: false,
            forms: {
              "Import From Repository": {
                fields: {
                  "Repo URL": {
                    label: 'Repo URL',
                    itemClass: KDInputView,
                    name: 'url'
                  }
                },
                buttons: {
                  'Import': {
                    title: 'Import',
                    type: 'submit',
                    style: 'modal-clean-green',
                    loader: {
                      color: "#ffffff",
                      diameter: 12
                    },
                    callback: function() {
                      return _this.ioController.importCourseFromRepository(modal.modalTabs.forms['Import From Repository'].inputs['Repo URL'].getValue(), 'git', function() {
                        console.log('Done importing from repository. Closing modal.');
                        return modal.destroy();
                      });
                    }
                  },
                  Cancel: {
                    title: 'Cancel',
                    type: 'modal-cancel',
                    callback: function() {
                      return modal.destroy();
                    }
                  }
                }
              },
              "Import From URL": {
                buttons: {
                  'Import': {
                    title: 'Import',
                    type: 'submit',
                    style: 'modal-clean-green',
                    loader: {
                      color: "#ffffff",
                      diameter: 12
                    },
                    callback: function() {
                      return _this.ioController.importCourseFromURL(modal.modalTabs.forms['Import From URL'].inputs['URL'].getValue(), function() {
                        console.log('Done importing from url. Closing modal.');
                        return modal.destroy();
                      });
                    }
                  },
                  Cancel: {
                    title: 'Cancel',
                    type: 'modal-cancel',
                    callback: function() {
                      return modal.destroy();
                    }
                  }
                },
                fields: {
                  "URL": {
                    label: 'URL',
                    itemClass: KDInputView,
                    name: 'url'
                  }
                }
              }
            }
          }
        });
      }
    }));
    runButton = new KDButtonView({
      cssClass: "cupid-green control-button run",
      title: 'Save and Run your code',
      tooltip: {
        title: 'Save and Run your code'
      },
      callback: function(event) {
        _this.liveViewer.active = true;
        return _this.ioController.saveFile(_this.courses, _this.lastSelectedCourse, _this.lastSelectedItem, _this.currentFile, _this.ace.getSession().getValue(), function() {
          return _this.liveViewer.previewCode(_this.editor.getValue(), _this.courses[_this.lastSelectedCourse].lectures[_this.lastSelectedItem].execute);
        });
      }
    });
    this.controlButtons.addSubView(this.courseButton = new KDButtonView({
      cssClass: "clean-gray editor-button control-button next hidden",
      title: 'Courses',
      tooltip: {
        title: 'Go to the course list'
      },
      callback: function(event) {
        return _this.emit('CourseRequested');
      }
    }));
    this.controlButtons.addSubView(this.lectureButton = new KDButtonView({
      cssClass: "clean-gray editor-button control-button previous",
      title: 'Lecture',
      tooltip: {
        title: 'Go to the current lecture'
      },
      callback: function(event) {
        return _this.emit('LectureRequested');
      }
    }));
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
    this.currentLang = ((_ref5 = this.courses[this.lastSelectedCourse || 0]) != null ? (_ref6 = _ref5.lectures) != null ? (_ref7 = _ref6[0]) != null ? _ref7.language : void 0 : void 0 : void 0) || 'javascript';
    this.controlView.addSubView(this.languageSelect.options.label);
    this.controlView.addSubView(this.languageSelect);
    this.aceWrapperView.addSubView(runButton);
    this.controlView.addSubView(this.controlButtons);
    this.liveViewer.setSplitView(this.splitView);
    this.liveViewer.setMainView(this);
    this.taskView.setMainView(this);
    this.taskOverview.setMainView(this);
    this.selectionView.setMainView(this);
    this.attachListeners();
    this.utils.defer(function() {
      return ($(window)).resize();
    });
    this.utils.wait(50, function() {
      var _ref8;

      ($(window)).resize();
      return (_ref8 = _this.ace) != null ? _ref8.resize() : void 0;
    });
    return this.utils.wait(1000, function() {
      return _this.ace.renderer.scrollBar.on('scroll', function() {
        if (_this.autoScroll === true) {
          return _this.setPreviewScrollPercentage(_this.getEditScrollPercentage());
        }
      });
    });
  };

  MainView.prototype.attachListeners = function() {
    var _this = this;

    this.on('LectureChanged', function(lecture) {
      var code, codeFile, files, language, _ref2;

      if (lecture == null) {
        lecture = 0;
      }
      _this.lastSelectedItem = lecture;
      _ref2 = _this.courses[_this.lastSelectedCourse].lectures[_this.lastSelectedItem], code = _ref2.code, codeFile = _ref2.codeFile, language = _ref2.language, files = _ref2.files;
      _this.currentFile = (files != null ? files.length : void 0) > 0 ? files[0] : 'tempfile';
      _this.ioController.readFile(_this.courses, _this.lastSelectedCourse, _this.lastSelectedItem, _this.currentFile, function(err, contents) {
        if (!err) {
          console.log(contents);
          return _this.ace.getSession().setValue(contents);
        } else {
          return console.log(err);
        }
      });
      _this.taskView.emit('LectureChanged', _this.courses[_this.lastSelectedCourse].lectures[_this.lastSelectedItem]);
      _this.taskOverview.emit('LectureChanged', {
        course: _this.courses[_this.lastSelectedCourse],
        index: _this.lastSelectedItem
      });
      _this.ace.getSession().setMode("ace/mode/" + language);
      _this.currentLang = language;
      _this.languageSelect.setValue(language);
      return _this.currentLecture = _this.lastSelectedItem;
    });
    this.on('CourseChanged', function(course) {
      _this.lastSelectedCourse = course;
      _this.emit('LectureChanged');
      return _this.emit('LectureRequested');
    });
    this.on('CourseRequested', function() {
      _this.splitView.setClass('out');
      _this.selectionView.setClass('in');
      _this.lectureButton.show();
      return _this.courseButton.hide();
    });
    this.on('LectureRequested', function() {
      _this.splitView.unsetClass('out');
      _this.selectionView.unsetClass('in');
      _this.courseButton.show();
      return _this.lectureButton.hide();
    });
    this.on('NextLectureRequested', function() {});
    return this.on('PreviousLectureRequested', function() {});
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
          return _this.ioController.saveFile(_this.courses, _this.lastSelectedCourse, _this.lastSelectedItem, _this.currentFile, _this.ace.getSession().getValue());
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



/* BLOCK STARTS /Source: /Users/arvidkahl/Applications/KodeLectures.kdapp/app/io.coffee */

var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

KodeLectures.Controllers.FileIOController = (function(_super) {
  __extends(FileIOController, _super);

  function FileIOController() {
    FileIOController.__super__.constructor.apply(this, arguments);
    this.kiteController = KD.getSingleton("kiteController");
    this.nickname = KD.whoami().profile.nickname;
    this.name = 'KodeLectures';
    this.appPath = "/Users/" + this.nickname + "/Applications";
    this.basePath = "" + this.appPath + "/" + this.name + ".kdapp";
    this.attachListeners();
  }

  FileIOController.prototype.importCourseFromRepository = function(url, type, callback) {
    var command,
      _this = this;

    if (type === 'git') {
      command = "cd " + this.basePath + "/courses; git clone " + url;
    }
    console.log("Importing a course from " + type + " repository at " + url);
    if (command) {
      return this.kiteController.run(command, function(err, res) {
        var manifestInstance, newCourseName;

        console.log('Import finished.', err);
        newCourseName = url.replace(/\/$/, '').substring(url.lastIndexOf("/") + 1, url.length).replace(/\.git$/, '');
        manifestInstance = FSHelper.createFileFromPath("" + _this.basePath + "/courses/" + newCourseName + "/manifest.json");
        return manifestInstance.fetchContents(function(err, res) {
          var course, e;

          console.log('Parsing manifest.json', err, res);
          if (err) {
            return callback(err);
          } else {
            try {
              course = JSON.parse(res);
            } catch (_error) {
              e = _error;
              console.log('Parse fauled with exception ', e);
            }
            if (course) {
              console.log("Successfully imported course " + course.title + " from " + url);
              _this.emit('NewCourseImported', course);
              return callback(course);
            }
          }
        });
      });
    }
  };

  FileIOController.prototype.importCourseFromURL = function(url, callback) {
    var baseUrl, command,
      _this = this;

    baseUrl = url;
    url = url.replace(/\/$/, '');
    if (!url.match(/manifest.json$/)) {
      url += '/manifest.json';
    }
    command = "curl -kL '" + url + "'";
    console.log("Importing a course from url " + url);
    return this.kiteController.run(command, function(err, res) {
      var course, e;

      if (err) {
        return console.log(err);
      } else {
        console.log('Parsing manifest.json');
        try {
          course = JSON.parse(res);
        } catch (_error) {
          e = _error;
          console.log('Parse failed with exception ', e);
        }
        if (course) {
          return _this.kiteController.run("mkdir " + _this.basePath + "/courses/" + course.path, function(err, res) {
            var file, lecture, _i, _j, _len, _len1, _ref, _ref1;

            _this.kiteController.run("curl -kL '" + url + "' > " + _this.basePath + "/courses/" + course.path + "/manifest.json");
            console.log("Importing course '" + course.title + "' from manifest.json data");
            if (course.lectures) {
              _ref = course.lectures;
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                lecture = _ref[_i];
                console.log("Importing lecture " + lecture.title);
                if (lecture.files) {
                  _ref1 = lecture.files;
                  for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                    file = _ref1[_j];
                    console.log("Importing file " + baseUrl + "/" + file + " to " + _this.basePath + "/courses/" + course.path + "/" + file);
                    _this.kiteController.run("curl -kL '" + baseUrl + "/" + file + "' > " + _this.basePath + "/courses/" + course.path + "/" + file, function(err, res) {
                      if (err) {
                        return console.log("File " + file + " could not be imported, an error occured: ", err);
                      } else {
                        return console.log("File " + file + " successfully imported");
                      }
                    });
                  }
                }
              }
            }
            return KD.utils.wait(2000, function() {
              _this.emit('NewCourseImported', course);
              return callback(course);
            });
          });
        }
      }
    });
  };

  FileIOController.prototype.readFile = function(courses, course, lecture, filename, callback) {
    var codeFileInstance, currentFile;

    currentFile = "" + this.basePath + "/courses/" + courses[course].path + "/" + filename;
    codeFileInstance = FSHelper.createFileFromPath(currentFile);
    return codeFileInstance.fetchContents(callback);
  };

  FileIOController.prototype.saveFile = function(courses, course, lecture, filename, value, callback) {
    var codeFileInstance, currentFile;

    if (callback == null) {
      callback = function() {};
    }
    currentFile = "" + this.basePath + "/courses/" + courses[course].path + "/" + filename;
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



/* BLOCK STARTS /Source: /Users/arvidkahl/Applications/KodeLectures.kdapp/index.coffee */

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