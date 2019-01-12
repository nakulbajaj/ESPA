# ESPA (Expert System for Patent Applications)

The Expert System for Patent Applications was developed by Nakul Bajaj as part of an advanced topics computer science course at school.

### Motivation

As someone who is interested in the intersection of technology and government, I realized that computer science can greatly benefit the average American to have more meaningful understandings of the law. One of the most overlooked parts of the law is patent law, which enables corporations, start-ups, and institutions to claim rights to their work and creativity. I developed ESPA to help people move beyond the complicated and entagled understanding of U.S. patent law, and help them save time on the patenting process so they can focus on invention and innovation.

### Vision vs. Status-Quo

Before I began building ESPA, I realized that it needed to model three important characteristics. It should be able to...

1. Serve as an <b> accurate legal assistant </b> for patent applications
2. Encompass <b> almost every detail </b> of patent law applications
3. Make it at least <b> ten times easier </b> for the average Joe to file their own patent

As of now, ESPA kind of meets requirement one, barely qualifies to even be considered as a contender for requirement two, and is too ugly to satisfy requirement three. Over the next year, I hope I can improve ESPA in these respects. I have included my goals in each of these categories, and hope I can achieve and replace them every three months.

1. Confirm with a real patent attorney that the current set of directions for each use case are correctly stated and reliable.
2. Create a system for people to generate their own specification sheet with their own set of claims.
3. Dramatically improve the terrible CLI with some hype ASCII art.

### Installation

This expert system was based on the capabilities and compatibilities of the Jess expert system shell. Although I hope to be able to port this program so it is more accessible with a GUI and perhaps even make it into its own native desktop application, we will have to stick to the limitations of Jess for now. With that being said, the steps below outline briefly how one can run this program on their own machine.

1. Download the Jess shell along with its resources by downloading the folder in this repo titled Jess71p1.zip.
2. Unzip the file and place the director on your desktop.
3. Download espa.clp from this repo and place it inside Jess71p1/bin.
4. Navigate to the bin folder from your terminal and run ./jess
5. Allow the Jess shell to load and then run "(batch espa.clp)"
6. Until I add a restart function, you will have to cancel the terminal process and run step 5 again to restart.

### Open-Source Philosophy

Three reasons I have committed to keeping ESPA open source:

1. I actually want people to be able to use this thing
2. Other people can help me maintain and update this expert system as U.S.C. Title 35 changes over time
3. Street cred
