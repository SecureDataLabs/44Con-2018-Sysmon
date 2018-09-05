## 44Con-2018-Sysmon
# Sys Mon! Why yu nuh logging dat?


#### Presented by: Charl van der Walt, Willem Mouton, Carl Morris and Wicus Ross

Sysmon from Microsoft is a very powerful host-level tracing tool, which can assist in detecting advanced threats on your network. Its free with Windows and a native extension of the Windows stack. Sysmon performs system activity deep monitoring and logs high-confidence indicators of attacks and compromise, but in contrast to common Antivirus / HIDS solutions … its stable, mature, simple and FREE!

#### Sysmon can monitor lots of interesting activities, including:
* Process creation (with full command line and hashes)
* Process termination
* Network connections
* File creation timestamps changes
* Driver/image loading
* Remote thread creation
* Raw disk access
* Process memory access

and more.

Another cool technology – Windows Event Forwarding (WEF) – can then used to read the event log on a device and forward selected events to a Windows Event Collector (WEC) server.

Put these two together, dump it into the SIEM, database or Elastic Stack of your choice, and you have yourself a pretty fine Windows Event monitoring and Threat Hunting platform.

In this presentation we will introduce these powerful tools and show you how to implement WEF and deploy Sysmon using your existing AD infrastructure and Group Policy so there is minimal impact on resources, and how to remotely tune and improve the configuration as necessary.

Win!

#### So what then?

We will then move on to explore how to extract ‘actionable’ intelligence from these logs – what to look for, how to spot it and what to do when you do find the mythical needle in the haystack, using real, practical examples from our own day-to-day operations.

Finally, we will share in detail some of our experiment (failed and successful) with extracting even more value from these logs, for example:

* Using Windows Event Logs via Sysmon to detect attacks on Web Applications
* Performing Event Correlation by pulling Sysmon into MiSP
* Using Python and scikit-learn to implement a semi supervised learning algorithm using a Markov chain random walk classifier to highlight anomalous events from large volumes of benign ones.

