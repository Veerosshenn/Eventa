class Event {
  final String poster, title, description, location, time;
  final double price;
  final int duration;

  Event(
      {required this.poster,
      required this.title,
      required this.description,
      required this.location,
      required this.price,
      required this.time,
      required this.duration});
}

List<Event> events = [
  Event(
    poster: "concert.webp",
    title: "HELP Music Fest 2024",
    description:
        "Join us for a night of incredible music, featuring live performances by top student bands and guest artists!",
    location: "BLH 2.2",
    price: 25.0,
    time: "11:30 a.m.",
    duration: 180,
  ),
  Event(
    poster: "tech_talk.webp",
    title: "Tech Talk: Future of AI",
    description:
        "Explore the latest trends in AI with industry experts. Learn how AI is shaping the future of technology and business.",
    location: "EMPH",
    price: 10.0,
    time: "8:00 a.m.",
    duration: 120,
  ),
  Event(
    poster: "film_night.webp",
    title: "Outdoor Movie Night",
    description:
        "Relax under the stars and enjoy a classic film with friends. Popcorn and drinks available!",
    location: "HLT 1.8",
    price: 5.0,
    time: "8:30 p.m.",
    duration: 150,
  ),
  Event(
    poster: "job_fair.webp",
    title: "HELP Career Fair 2024",
    description:
        "Connect with top employers, explore job opportunities, and get career advice from professionals.",
    location: "HLT 1.6",
    price: 0.0,
    time: "10:00 a.m.",
    duration: 240,
  ),
  Event(
    poster: "hackathon.jpg",
    title: "HELP Hackathon",
    description:
        "Compete in an exciting 24-hour coding challenge. Solve real-world problems and win amazing prizes!",
    location: "EMPH",
    price: 15.0,
    time: "8:30 a.m.",
    duration: 1440,
  ),
  Event(
    poster: "workshop.webp",
    title: "Photography Workshop",
    description:
        "Learn the art of photography from professionals. Hands-on training with tips on capturing stunning shots.",
    location: "ALH 2.5",
    price: 20.0,
    time: "2:00 p.m.",
    duration: 180,
  ),
];
