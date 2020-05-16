function start_up() {
  // alert("1234");

  App.room = App.cable.subscriptions.create("CribChannel",
    {

    // Called when the subscription is ready for use on the server
    connected: function() {
      // alert("xx");
      //NB key size limited to 1024 since any longer takes too long to load

      message_packets=null;
      crypt = new JSEncrypt({default_key_size: 1024});
      client_private_key = crypt.getPrivateKey();
      client_public_key = crypt.getPublicKey();
      return App.room.send_client_public_key(client_public_key);
    },

    disconnected: function() {},
    //Called when the subscription has been terminated by the server

    received: function(data) {
      var encrypted_message, encrypted_messages, past_messages_downloaded, unencrypted_message, insert;
      stgs = ["player1_hand", "player1_play", "player2_hand", "player2_play", "player3_hand", "player3_play", "player4_hand", "player4_play", "player1_name", "player2_name", "player3_name", "player4_name"];
      stgs.forEach (function(stg) {
        if (data[stg] != undefined){
          document.getElementById(stg).innerHTML = data[stg];
        }
    })

      if (data['your_hand'] != undefined){
        document.getElementById("your_hand").innerHTML = data['your_hand'];
      }
      if (data['your_play'] != undefined){
        document.getElementById("your_play").innerHTML = data['your_play'];
      }
      if (data['other_hand'] != undefined){
        document.getElementById("other_hand").innerHTML = data['other_hand'];
      }
      if (data['other_play'] != undefined){
        document.getElementById("other_play").innerHTML = data['other_play'];
      }
      if (data['deck'] != undefined){
        document.getElementById("deck").innerHTML = data['deck'];
      }
      if (data['crib'] != undefined){
        document.getElementById("crib").innerHTML = data['crib'];
      }
      if (data['hands_and_score'] != undefined){
        // alert(data['scores'] + "; " + data['names'] + "; " + data['player_number']);
        document.getElementById("hands_and_score").innerHTML = data['hands_and_score'];
        update_scoreboard(data['scores'], data['names'], data['player_number']);
      }
      if (data['scores'] != undefined){
        update_scoreboard(data['scores'], data['names'], data['player_number']);
      }
      if (data['dealrequest'] != undefined){
        document.getElementById("dealrequest").innerHTML = data['dealrequest'];
      }

      if (data['reset_requests'] != undefined){
        document.getElementById("reset_requests").innerHTML = data['reset_requests'];
      }


      // if (data['server_public_key']) {
      //
      //   server_public_key = data['server_public_key'];
      //   if (past_messages_downloaded != true) {
      //     past_messages_downloaded = true;
      //     return App.room.request_past_messages("newest");
      //   }
      //
      // // } else {
      //
      //
      //   // if (data['previous_messages']) {
      //   //   previous_messages = data['previous_messages'];
      //   //   next_messages = data['next_messages'];
      //   // }
      //   //
      //   // if (data['total_no_packets']) {
      //   //   if(message_packets==null) {
      //   //     message_packets= new Array(Number(data['total_no_packets'])).fill("");
      //   //   }
      //   //   message_packets[data['packet_number']]  = data['message'];
      //   //   encrypted_message = "";
      //   //   if(check_all_downloaded()) {
      //   //     message_packets.forEach (function(message) {
      //   //       encrypted_message += message;
      //   //       });
      //   //       message_packets = null;
      //   //   }
      //   // } else {
      //   //   encrypted_message = data['message'];
      //   // }
      //   //
      //   // insert = $('#action_insert').html();
      //   //
      //   // if (encrypted_message !="") {
      //   //
      //   //   var crypt = new JSEncrypt();
      //   //   crypt.setPrivateKey(client_private_key);
      //   //   unencrypted_message = "";
      //   //   encrypted_messages = encrypted_message.split("\t\n");
      //   //
      //   //   encrypted_messages.forEach(function(message) {
      //   //
      //   //     encrypted_lines = message.split("\t");
      //   //     encrypted_lines.forEach(function(line) {
      //   //       unencrypted_message += crypt.decrypt(line) ;
      //   //       });
      //   //
      //   //       unencrypted_message = unencrypted_message.replace('<div id="insert" />', insert);
      //   //     });
      //   //
      //   //
      //   //   if (data['action']=="add") {
      //   //     if (allow_new_messages=="yes") {
      //   //
      //   //     $('#messages').prepend(unencrypted_message);
      //   //     }
      //   //   } else {
      //   //
      //   //
      //   //     $('#messages').prepend(unencrypted_message);
      //   //   }
      //   // }
      //   // return ""
      // }
    },
    send_message: function(message_content) {
      // crypt = new JSEncrypt();
      // crypt.setPublicKey(server_public_key);
      // var encrypted_message;
      // encrypted_message = crypt.encrypt(message_content);
      return this.perform('message', {
        message_forum_name: message_forum_name, message: encrypted_message
      });
    // },
    // send_action: function(message_number, action_text, action_date, action_myusers) {
    //   crypt = new JSEncrypt();
    //   crypt.setPublicKey(server_public_key);
    //   var encrypted_action = crypt.encrypt(action_text);
    //   return this.perform('action', {
    //     message_number: message_number, action_text: encrypted_action, action_date: action_date, action_myusers: action_myusers
    //   });
    // },
    //
    // send_client_public_key: function(key) {
    //   return this.perform('client_public_key', {
    //     key: key
    //   });
    // },
    // request_past_messages: function(message_number) {
    //   return this.perform('request_past_messages', {
    //     message_forum_name: message_forum_name, message_number: message_number
    //   });
    }
  },
  // $(document).on('keypress', '[data-behavior~=room_speaker]', function(event) {
  //   if (event.keyCode === 13) {
  //     App.room.send_message(event.target.value);
  //     event.target.value = '';
  //     return event.preventDefault();
  //   }
  // })
  // ,
  // $(document).on('keypress', '[data-behavior~=action_text]', function(event) {
  //   if (event.keyCode === 13) {
  //     var message_number = event.target.id.replace("text","");
  //     save_action(message_number, event.target.value);
  //     event.keyCode = 0;
  //   }
  //   if (event.keyCode === 65) {
  //     alert("test");
  //     event.keyCode = 0;
  //   }
  // })

);
}

// function messagekeypress (event) {
//   event = event || window.event;
//   if (event.keyCode === 13) {
//     App.room.send_message(event.target.value);
//     event.target.value = '';
//     return event.preventDefault();
//   }
// };
//
// function actionkeypress (event) {
//   event = event || window.event;
//   if (event.keyCode === 13) {
//     var message_number = event.target.id.replace("text","");
//     save_action(message_number, event.target.value);
//     event.target.value = '';
//     return event.preventDefault();
//   }
// };
//
// function oldest()  {
//   stg = "";
//   myusers_for_message_forum.forEach (function(myuser_id) {
//     if (document.querySelector("#apa21").querySelector("#action_user"+myuser_id).checked) {
//       stg += myuser_id + "; ";
//       }
//     });
// };
//
// function newest()  {
//   $('#messages').empty();
//   App.room.request_past_messages("newest");
// };
//
// function next_messages_call()  {
//   $('#messages').empty();
//   App.room.request_past_messages(next_messages);
// };
//
// function previous_messages_call()  {
//   $('#messages').empty();
//   App.room.request_past_messages(previous_messages);
// };
//
// function messages_call(message_number)  {
//   $('#messages').empty();
//   App.room.request_past_messages(message_number);
// };
//
//   function test() {
//     // alert(document.querySelector("#apa31").querySelector("#action_user1").checked);
// }
//
// function check_all_downloaded()  {
//   var flag = true;
//   message_packets.forEach (function(message) {
//     if (message == "") {flag = false}
//     });
//     return flag;
//   };
//
// function action(messager_number) {
//   alert(document.querySelector('.messageCheckbox:checked').value);
// }
//
//
// function show_action(message_number) {
//     document.getElementById("apa" + message_number).style.display = "block";
//     document.getElementById("act_but" + message_number).style.display = "none";
//     // document.getElementById("apc" + message_number).style = "min-height: 100px; max-height: 250px; overflow: auto;";
//
// }
//
// function save_action_button(message_number) {
//   var action_content = document.querySelector("#text"+message_number).value;
//   save_action(message_number, action_content);
// }
//
// function save_action(message_number, action_content) {
//     var action_date = document.querySelector("#apa"+message_number).querySelector("#action_date").value
//     var action_myusers_stg = "";
//     myusers_for_message_forum.forEach (function(myuser_id) {
//       if (document.querySelector("#apa"+message_number).querySelector("#action_user"+myuser_id).checked) {
//         action_myusers_stg += myuser_id + "; ";
//         }
//       });
//     crypt = new JSEncrypt();
//     App.room.send_action(message_number, action_content, action_date, action_myusers_stg);
//     document.getElementById("apa" + message_number).style.display = "none";
//     document.getElementById("act_but" + message_number).style.display = "block";
// }
//
//
// function show_hide_email(on_flag) {
//     if(on_flag) {
//     document.getElementById("email_users").style.display = "block";
//   } else {
//     document.getElementById("email_users").style.display = "none";
//   }
// }
//
// function job_email_radio(email_type) {
//
//   if (job_email_type != email_type) {
//
//     if (email_type == "avail"){
//       job_email_other = document.querySelector("#email_message").value;
//       $("#email_message").val(job_email_availability);
//     } else {
//       job_email_availability=document.querySelector("#email_message").value;
//       $("#email_message").val(job_email_other);
//     };
//     job_email_type = email_type;
//   };
// }
