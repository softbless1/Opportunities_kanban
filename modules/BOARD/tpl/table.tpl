<link rel="stylesheet" href="custom/include/lib/jkanban/jkanban.min.css" />
<script src="custom/include/lib/jkanban/jkanban.min.js"></script>
<div id="myKanban"></div>

<div id="MyModal" class="modal fade bd-example-modal-lg" tabindex="-1" role="dialog" aria-labelledby="myLargeModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
            <div class="modal-header-bar">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>

        <div class="modal-content" id="modal-body">
            <iframe src="" frameborder="0" id="iframemodal"></iframe>

        </div>
    </div>
</div>

<script>

    {literal}
    function loadmodalbody(id) {
        $("#iframemodal").attr("src" , 'index.php?module=' + {/literal}'{$RECIPIENT_MODULE}'{literal} + '&hiddenMenu=1&action=DetailView&record='+id);
        var heightWindow = window.innerHeight - 0.1 * window.innerHeight;
        $("#iframemodal").innerHeight(heightWindow);
    }
    {/literal}
    var configBord = {$bordConfig|@json_encode};
    var stages={$STAGES};
    const RECIPIENT_MODULE='{$RECIPIENT_MODULE}';
    var countRecord={$countRecord};
    {literal}
    var bordsData=[];
    var counter=0;
    for (var key in stages) {

        bordsData[counter]={
            'id': "_" + key.replace(/\s+/g, ''),
            'title': stages[key],
            'key':key,
            'class': key.replace(/\s+/g, ''),
            'item': []
        };
        counter++;

    }
    const bordValue=bordsData;


    var KanbanTest = new jKanban({
        element: "#myKanban",
        gutter: "1px",
        widthBoard: "250px",
        dragBoards: false,
        itemHandleOptions:{
            enabled: false,
        },
        click: function(el) {
            var id = el.getAttribute('data-idopp');
      
        },
        dropEl: function(el, target, source, sibling){
            var id = el.getAttribute('data-idopp');
            for (var i = 0; i < bordsData.length; i++) {
                if(bordsData[i]["id"] == target.parentElement.getAttribute('data-id') ){
                    var newStatus= bordsData[i]["key"];
                    var data = {
                        "action":"save",
                        'id': id,
                        {/literal}'{$bordConfig.stages_field}'{literal}: newStatus
                    };
                    ajax_request('index.php?module=' + {/literal}'{$RECIPIENT_MODULE}'{literal} + '&action=save&to_pdf=true', 'html', data, 'nohtink');
                }
            }
        },
        buttonClick: function(el, boardId) {
            // create a form to enter element
            var formItem = document.createElement("form");
            formItem.setAttribute("class", "itemform");
            formItem.innerHTML =
                '<div class="form-group"><textarea class="form-control" rows="2" autofocus></textarea></div><div class="form-group"><button type="submit" class="btn btn-primary btn-xs pull-right">Submit</button><button type="button" id="CancelBtn" class="btn btn-default btn-xs pull-right">Cancel</button></div>';

            KanbanTest.addForm(boardId, formItem);
            formItem.addEventListener("submit", function(e) {
                e.preventDefault();
                var text = e.target[0].value;
                KanbanTest.addElement(boardId, {
                    title: text
                });
                formItem.parentNode.removeChild(formItem);
            });
            document.getElementById("CancelBtn").onclick = function() {
                formItem.parentNode.removeChild(formItem);
            };
        },
        addItemButton: false,
        boards: bordValue
    });

    $(document).ready(function () {
	
        if(countRecord < 100){
            getAllStage();
        }
        if(countRecord >= 100  ){
            getDataFromStage();
        }
    });


    function getOthersRecord() {
        for (index = 0; index < configBord['stages'].length; ++index) {
            if(configBord['stages'][index]['show']) {
                var limitMax = configBord['stages'][index]['loadItems'] + configBord['limitIterationITems'];
                ajax_request('index.php?module=BOARD&recipient_module=' + RECIPIENT_MODULE + '&action=getData&where[]=' + configBord.stages[index]['name'] + '&to_pdf=true&limitMin=' + configBord['stages'][index]['loadItems'] + '&limitMax=' + limitMax, 'JSON', '', 'setItems')
            }
        }

    }
    function getDataFromStage() {
        for (index = 0; index < configBord['stages'].length; ++index) {
            if(configBord['stages'][index]['show']) {
                ajax_request('index.php?module=BOARD&recipient_module=' + RECIPIENT_MODULE + '&action=getData&where[]=' + configBord.stages[index]['name'] + '&to_pdf=true', 'JSON', '', 'setItems');
            }
        }
    }

    function getAllStage() {
        ajax_request('index.php?module=BOARD&recipient_module=' + RECIPIENT_MODULE + '&action=getData&to_pdf=true','JSON','','setItems');
    }
    function setItems(data) {
        for (var key in data) {
            for (index = 0; index < data[key].length; ++index) {
				var title = "";
				var account = [];
				
				var isShowAccountLinks = data[key][index]['headerFields'].includes("account_name") && data[key][index]['headerFields'].includes("account_id");
				
				for(itemIndex= 0; itemIndex < data[key][index]['beanCardName'].length; itemIndex++) {
					var link = data[key][index]['beanCardName'][itemIndex]['name'];
					var fieldName = data[key][index]['beanCardName'][itemIndex]['fieldName'];
					if(fieldName == "name") {
						link = "<a class='kanban-link' href='?action=ajaxui#ajaxUILoc=index.php%3Fmodule%3D"+RECIPIENT_MODULE+"%26action%3DDetailView%26record%3D"+data[key][index]['id']+"'>"+data[key][index]['beanCardName'][itemIndex]['name']+"</a>"
					} 
					
					if(isShowAccountLinks) {
						if(fieldName == "account_name") {
							account['account_name'] = data[key][index]['beanCardName'][itemIndex]['name'];
							continue;
						} else if(fieldName == "account_id") {
							account['account_id'] = data[key][index]['beanCardName'][itemIndex]['name'];
							continue;
						}
					}
					
					title = title + "<div>" + link + "</div>";
					
					
				}
				
				if(account['account_name'] != undefined && account['account_id'] != undefined) {
					title += "<div><a class='kanban-link' href='?action=ajaxui#ajaxUILoc=index.php%3Fmodule%3DAccounts%26action%3DDetailView%26record%3D"+account['account_id']+"'>"+account['account_name']+"</a></div>"
				}
				
				KanbanTest.addElement("_" + key.replace(/\s+/g, ''),{
					title: title,
					idopp:data[key][index]['id'],
				});
            }
        }

    }
    function ajax_request(url,dataType,urlParams,functionName) {
        $.ajax({
            url: url,         /* Куда пойдет запрос */
            method: 'post',             /* Метод передачи (post или get) */
            dataType: dataType,          /* Тип данных в ответе (xml, json, script, html). */
            data: urlParams,     /* Параметры передаваемые в запросе. */
            success: function(data){   /* функция которая будет выполнена после успешного запроса.  */
                if(functionName == 'setItems'){
                    setItems(data);
                }
            }
        });

    }

</script>
    <style>
        #myKanban{
        {/literal}
            height: auto;
            overflow-y: auto;
            overflow-x: scroll;
        {literal}
        }
		.kanban-container {
			display: flex;
		}
        .kanban-drag{
        {/literal}
            height: {$bordConfig.kanban.kanbandragHeight}px;
            overflow-y: scroll;
        {literal}
        }
        .drag_handler{
            float: none;
        }
        .modal-header-bar{
            z-index: 1000;
            position: relative;
        }
        .close{
            padding: 5px;
            position: absolute;
            z-index: 1000;
            right: 10px;
            top: 20px;
        }
        #iframemodal {
            width: 100%;
            height: 100%;
        }
		.kanban-link:hover {
		  text-decoration: underline !important;
		}

		.kanban-item.gu-mirror {
			transform: rotate(4deg) !important;
			cursor: grabbing !important;
			cursor: -moz-grabbing;
			cursor: -webkit-grabbing;
		}

		.kanban-item div:first-child, .kanban-item div:first-child a {
		  font-weight: bold !important;
		  margin-left: 0.1px;
		  margin-top: 5px;
		}

		.kanban-item div {
		  line-height: 13px;
		  margin-bottom: 10px;
		}

		.kanban-board header {
			padding: 20px !important;
		}

		.kanban-item {
			padding: 10px 10px 8px 10px !important;
			margin-bottom: 13px !important;
			background-color: #fff !important;
			box-shadow: 0 0px 2px 0 rgba(0,0,0,.14),0 7px 10px -5px rgba(0, 0, 0, 0.4) !important;
			width: auto;
			border-radius: 0;
			border: none !important;
			cursor: pointer !important;
		}
		.kanban-board .kanban-drag {
		  padding: 20px;
		  max-height: 500px;
		  padding-top: 0 !important;
		  overflow-y: auto;
		}

		.kanban-board {
			margin: 0 6px !important;
		}

		.drag_handler_icon::after {
		  bottom: 4px !important;
		}

		.kanban-item {
			padding: 10px !important;
		}

		.drag_handler_icon::before {
		  top: 4px !important;
		}

		#myKanban {
			overflow: initial !important;
		}

		.drag_handler_icon {
			width: 15px !important;
			height: 2px !important;
		}
    </style>
{/literal}