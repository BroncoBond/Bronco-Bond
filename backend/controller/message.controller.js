const Message = require("../model/message.model");
const Conversation = require("../model/conversation.model");

exports.sendMessage = async (req, res) => {
    try {
        const {message, receiverId} = req.body;
        const senderId = req.user._id;
        
        let conversation = await Conversation.findOne({
            participants: {
                $all: [senderId, receiverId]
            }
        })

        if(!conversation) {
            conversation = await Conversation.create({
                participants: [senderId, receiverId],
            })
        }

        const newMessage = new Message({
            senderId,
            receiverId,
            message
        });

        if(newMessage) {
            conversation.message.push(newMessage._id);
        }

        res.status(201).json(newMessage);

    } catch (err) {
        console.log("Error in sendMessage controller: ", err.message);
        res.status(500).json({ error: "Internal server error"});
    }
}