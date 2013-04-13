# > index.coffee
  {MainView} = KodeLectures.Views  
#do ->
  
  KD.enableLogs()

  console.log 'Development version of KodeLectures starting...'  
    #
  loader     = new KDView
    cssClass : "KodeLectures loading"
    partial  : "Loading KodeLectures..."  
  
  appView.addSubView loader
  
  #mainView = {}
  
  #markdownModal    = new KDModalView
    #width          : window.innerWidth-100
    #height         : window.innerHeight-100
    #overlay        : no
    #title          : 'KodeLectures'
    #buttons        :
      #Yes          :
        #loader     :
          #color    : "#ffffff"
          #diameter : 16
        #style      : "modal-clean-gray"
        #callback   : ->
          #new KDNotificationView
            #title  : "Clicked yes!"
          #
          #value = mainView.ace.getSession().getValue()
          #console.log value
          #
          #markdownModal.destroy()
          #return value
      #No           :
        #loader     :
          #color    : "#ffffff"
          #diameter : 16
        #style      : "modal-clean-gray"
        #callback   : ->
          #new KDNotificationView
            #title  : "Clicked no!"          
          #
          #value = mainView.ace.getSession().getValue()
          #console.log value
          #
          #markdownModal.destroy()
          #return value
          #
  #markdownModal.addSubView loader
    
  require ["ace/ace"], (Ace)=>
            
      mainView   = new MainView
        cssClass : "marKDown"
        ace      : Ace

      #markdownModal.removeSubView loader
      #markdownModal.addSubView mainView
      #markdownModal.$('.kdmodal-content').height window.innerHeight-95
      appView.removeSubView loader
      appView.addSubView mainView