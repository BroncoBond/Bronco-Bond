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
            conversation.messages.push(newMessage._id);
        }

        // Socket Io Functions



        await Promise.all([conversation.save(), newMessage.save()]);

        res.status(201).json(newMessage);

    } catch (err) {
        console.log("Error in sendMessage controller: ", err.message);
        res.status(500).json({ error: "Internal server error"});
    }
}

exports.getMessage = async (req, res) => {
    try {
        const { userToChatId } = req.body;
		const currentUserId = req.user._id;

		const conversation = await Conversation.findOne({
			participants: { $all: [currentUserId, userToChatId] },
		}).populate("messages");

		if (!conversation) return res.status(200).json([]);

		const messages = conversation.messages;

		res.status(200).json(messages);
    } catch (err) {
        console.log("Error in sendMessage controller: ", err.message);
        res.status(500).json({ error: "Internal server error"});
    }
}