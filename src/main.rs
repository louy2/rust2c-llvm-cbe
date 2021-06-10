use planck_ecs::{join, Components, DispatcherBuilder, Entities, IntoSystem, SystemResult, World};

#[derive(Debug, PartialEq)]
enum Color {
    Red,
    Blue,
    Green,
}

fn change_color_system(colors: &mut Components<Color>) -> SystemResult {
    for color in join!(&mut colors) {
        *color = Color::Blue;
    }
    Ok(())
}

fn main() {
    let mut world = World::default();
    let mut dispatcher = DispatcherBuilder::default()
        .add(change_color_system)
        .build(&mut world);

    let entity1 = world.get_mut_or_default::<Entities>().create();
    world
        .get_mut_or_default::<Components<_>>()
        .insert(entity1, Color::Red);

    dispatcher.run_seq(&mut world).unwrap();
}
