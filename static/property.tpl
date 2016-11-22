SetVar(
	global = 0,
	type_new_page_id = TxId(NewPage),
	type_new_contract_id = TxId(NewContract),
	type_append_id = TxId(AppendPage),
	type_new_table_id = TxId(NewTable),
	sc_conditions = "$citizen == #wallet_id#",
    sc_value1 = `contract AddProperty {
                 	tx {
                         Coords string "map"
                 	CitizenId string
                 	Name string

                     }

                 	func main {
                 		DBInsert(Table( "property"), "coords,citizen_id,name", $Coords, $CitizenId, $Name)
                 	}
                 }`,
    sc_value2 = `contract EditProperty {
                 	tx {
                 		PropertyId  int
                 	        Coords string "map"
                 	        CitizenId string
                 	        Name string
                 	}
                 	func main {
                 	  DBUpdate(Table( "property"), $PropertyId, "coords,citizen_id,name", $Coords, $CitizenId, $Name)
                 	}
                 }`,

    page_add_property = `
            Navigation( Govenment )
            PageTitle : Add Property
            TxForm{ Contract: AddProperty}
            PageEnd:`

    page_edit_property = `Title:EditProperty
                          Navigation(LiTemplate(Citizen),Editing property)
                          PageTitle: Editing property
                          ValueById(#state_id#_property, #PropertyId#, "name,citizen_id,coords", "Name,CitizenId,Coords")
                          TxForm{ Contract: EditProperty}
                          PageEnd:`

    page_government = `TemplateNav(AddProperty, AddProperty) BR()

             MarkDown : ## Property
             Table{
                 Table: #state_id#_property
                 Order: id
                 Columns: [[ID, #id#], [Name, #name#], [Coordinates, #coords#], [Citizen ID, #citizen_id#], [Edit,BtnTemplate(EditProperty,Edit,"PropertyId:#id#")]]
             }`

)
TextHidden( sc_value1, sc_value2, sc_conditions )
Json(`Head: "Adding account column",
	Desc: "This application adds citizen_id column into account table.",
	OnSuccess: {
		script: 'template',
		page: 'government',
		parameters: {}
	},
	TX: [
		{
		Forsign: 'global,id,value,conditions',
		Data: {
			type: "AddContract",
			typeid: #type_new_contract_id#,
			global: #global#,
			value: $("#sc_value1").val(),
			conditions: $("#sc_conditions1").val()
			}
	   },
		{
		Forsign: 'global,id,value,conditions',
		Data: {
			type: "AddContract",
			typeid: #type_new_contract_id#,
			global: #global#,
			value: $("#sc_value2").val(),
			conditions: $("#sc_conditions2").val()
			}
	   },
        	   {
        		Forsign: 'table_name,columns,permissions',
        		Data: {
        			type: "NewTable",
        			typeid: #type_new_table_id#,
        			table_name : "#state_id#_property",
        			columns: "{'citizen_id','coords','name'}",
        			permissions: "$citizen == #wallet_id#"
        		}
        		},
           {
           		Forsign: 'global,name,value',
           		Data: {
           			type: "AppendPage",
           			typeid: #type_append_id#,
           			name : "goventment",
           			value: "#page_goventment#",
           			global: #global#
           		}
           },
                   {
                   		Forsign: 'global,name,value,conditions',
                   		Data: {
                   			type: "NewPage",
                   			typeid: #type_new_page_id#,
                   			name : "EditProperty",
                   			value: "#page_edit_property#",
                   			global: #global#,
                    		conditions: "$citizen == #wallet_id#",
                   		}
                   },
                           {
                           		Forsign: 'global,name,value,conditions',
                           		Data: {
                           			type: "NewPage",
                           			typeid: #type_new_page_id#,
                           			name : "AddProperty",
                           			value: "#page_add_property#",
                           			global: #global#,
                            		conditions: "$citizen == #wallet_id#",
                           		}
                           }
	]
`)