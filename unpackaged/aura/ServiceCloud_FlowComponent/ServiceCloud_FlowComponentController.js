({
  init : function (cmp) {
    var flow = cmp.find("flow");
    var inputVariables = [
      {
        name : 'recordId',
        type : 'String',
        value : cmp.get("v.recordId")
      }
    ];
    flow.startFlow("ServiceCloud_CreateCase", inputVariables);
  },

  statusChange : function (cmp, event) {
    if (event.getParam('status') === "FINISHED") {
      //Do something
    }
  }
})