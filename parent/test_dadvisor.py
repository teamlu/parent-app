"""
File: test_dadvisor.py
Description: This file tests the following methods:
             1. get_parent_advice: Analyzes a podcast transcript to generate parent coaching advice.
             2. main: Main entrypoint that triggers the get_parent_advice function.

Steps: You can invoke the function from the command line with:
       > modal run dadvisor.py --chat-transcript "Where are my kids? Did everyone leave me? Or are they hiding? Good morning. What are you guys doing? Oh, we're having a conversation about pets. What is the reason you don't want to have a pet, Ari? Because mommy said we can't. Mommy said we can't? I said not yet. Oh, not yet. Okay. How do pets make you feel? Happy, but now angry. Angry. Is there something that happened before that made you angry about the pets? It was mommy that made me angry about the pets. Oh, mommy made you feel angry about it. I told them that maybe in two to three years, when our kids are all a little bit older, and we don't have so many jobs to do for babies and little kids, then we can talk about getting a pet. I see. So you don't want to be, it sounds like you don't want to wait to have a pet, right Ari? Yeah, but now I don't. Now you don't want to have one? No. I understand how you feel Ari."
       
       If you're satisfied, deploy it with:
       > modal deploy backend.py
"""

import modal

stub = modal.Stub("parent-app")
parent_image = modal.Image.debian_slim().pip_install(
    "https://github.com/openai/whisper/archive/9f70a352f9f8630ab3aa0d06af5cb9532bd8c21d.tar.gz",
    "openai")

@stub.function(image=parent_image, secret=modal.Secret.from_name("my-openai-secret"), timeout=1200)
def get_parent_advice(chat_transcript):
    import openai

    instructPrompt = """
    You will be given the transcript of a father and son's dialogue. What are some ways this father could have asked questions to engage
    his son developmentally? Then do these steps:

    1. Re-frame the bulleted list as if you were a parent coach speaking to me in real-time. Provide a hook, use structure, be brief, give clear examples, and be encouraging in tone.
    2. Re-write it as a reply to a reader's question in a New York Times' question-and-answer column.
    3. Recognize the reader's need to engage their child in more profound and developmental conversations.
    4. Adapt the content to suit the format of a newspaper column, focusing on brevity, clarity, and relevance to a wider readership.
    5. Organize the advice into 3 key areas to make it easy to follow, each with a tip and example.
    6. Ensure the language is positive, reassuring, and non-judgmental to empower the reader in their parenting journey.
    7. Include specific examples and phrasing to give the reader tangible ways to implement the suggestions.
    8. End with encouragement and well-wishes, reinforcing the positive aspects of the reader's existing approach and fostering a sense of connection.
    9. Start with "Dear Dad" and sign off with your name as "Ari".
    """
    
    text = """
    Dear Dad,

    It's beautiful to see the loving exchange between you and your child, especially during a daily activity like dinner. The way you're engaging your child is already commendable. Here's how you could further enrich these precious moments:

    Encourage Descriptive Language and Healthy Choices:
    - Try This: Ask them to describe the taste or texture of foods.
    - For Example: "What do the carrots taste like? Can you describe it?"

    Promote Responsibility and Independence:
    - Try This: Involve them in decisions and praise their efforts.
    - For Example: "Would you like to pick a vegetable for dinner tomorrow? You did a great job helping me clean up!"

    Foster Creativity and Imagination:
    - Try This: Encourage them to come up with new food combinations.
    - For Example: "How could we make the carrots taste better next time? What would you like to mix with them?"

    Your interactions during dinner time are already filled with love and guidance. These additional insights can bring even more depth, learning, and fun to your mealtime conversations.

    Enjoy these special moments with your little man. They grow up fast!

    Ari
    """

    chatOutput = openai.ChatCompletion.create(
        model="gpt-3.5-turbo-16k",
        messages=[{"role": "system", "content": instructPrompt},
                {"role": "user", "content": "Did you like your dinner, buddy? Yes, Daddy, I like chicken! That's great! How about the carrots? Did you eat them all? No, carrots yucky! Oh, that's okay. Maybe next time we can try them with something else. Want dessert? Yes, please, ice cream! Ice cream it is, but first, let's clean up your plate. Can you help me? Okay, Daddy! Great job! You're such a big helper. Thank you, Daddy. You're welcome, buddy. Now, what flavor of ice cream do you want? Chocolate! Chocolate is my favorite too. We can enjoy it together. Yay! Then can we read a book? Absolutely! You pick the book, and I'll scoop the ice cream. I love you, Daddy. I love you too, my little man."},
                {"role": "assistant", "content": text},
                {"role": "user", "content": chat_transcript}
                ]
        )
    
    parentAdvice = chatOutput.choices[0].message.content
    return parentAdvice

@stub.local_entrypoint()
def main(chat_transcript):
    output = get_parent_advice.call(chat_transcript=chat_transcript)
    print(output)
